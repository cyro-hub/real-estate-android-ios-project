import passport from "passport";
import { injectable } from "tsyringe";
import { Request, Response, NextFunction } from "express";
import AsyncHandler from "../services/utils/asyncHandlerService";
import { User } from "../models/user";
import Jwt from "../services/utils/jsonwebservices";
import "../config/passport";
import ApiResponse from "../services/utils/apiResponseService";
import { Types } from "mongoose";
import { Token } from "../models/token";
import { verifyGoogleToken } from "../config/googleVerifier";

@injectable()
export default class AuthController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private jwt: Jwt,
    private apiResponse: ApiResponse
  ) {}

  register = this.asyncHandler.handler(async (req: Request, res: Response) => {
    const { email, password, fullName } = req.body;

    if (!email || !password) {
      return this.apiResponse
        .error("Email and password are required")
        .send(res, 400);
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return this.apiResponse.error("User already exists").send(res, 409);
    }

    const bcrypt = await import("bcryptjs");
    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await User.create({
      email,
      password: hashedPassword,
      isVerified: true,
      provider: "local",
      fullName,
    });

    const accessToken = this.jwt.generateAccessToken({
      _id: newUser.id,
      email: newUser.email,
    });

    const refreshToken = this.jwt.generateRefreshToken({ _id: newUser.id });

    return this.apiResponse
      .auth(
        "User registered successfully",
        {
          accessToken,
          refreshToken,
          tokenType: "Bearer",
          expiresIn: this.jwt.accessTokenExpiry,
        },
        {
          _id: newUser._id,
          email: newUser.email,
          fullName: newUser.fullName,
          image: newUser.image || "",
          phone: newUser.phone || "+237 --- --- ---",
          provider: newUser.provider,
        }
      )
      .send(res, 201);
  });

  login = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      passport.authenticate(
        "local",
        { session: false },
        (err: any, user: any, info: any) => {
          if (err) return next(err);

          if (!user) {
            return this.apiResponse
              .error(info?.message || "Unauthorized")
              .send(res, 401);
          }

          const accessToken = this.jwt.generateAccessToken({
            _id: user.id,
            email: user.email,
          });

          const refreshToken = this.jwt.generateRefreshToken({ _id: user.id });

          return this.apiResponse
            .auth(
              "Login successful",
              {
                accessToken,
                refreshToken,
                tokenType: "Bearer",
                expiresIn: this.jwt.accessTokenExpiry,
              },
              {
                _id: user._id,
                email: user.email,
                fullName: user.fullName,
                image: user.image || "",
                phone: user.phone || "+237 --- --- ---",
                provider: user.provider,
              }
            )
            .send(res, 200);
        }
      )(req, res, next);
    }
  );

  loginWithGoogle = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const { idToken } = req.body;

      if (!idToken) {
        return this.apiResponse.error("Missing Google ID token").send(res, 400);
      }

      const payload = await verifyGoogleToken(idToken);

      if (!payload?.email) {
        return this.apiResponse.error("Invalid Google token").send(res, 400);
      }

      // Find or create user
      let user = await User.findOne({ email: payload.email });

      if (!user) {
        user = await User.create({
          email: payload.email,
          fullName: payload.name,
          image: payload.picture,
          googleId: payload.sub,
          provider: "google",
          password: "google",
        });
      }

      // Create JWTs
      const accessToken = this.jwt.generateAccessToken({
        _id: user.id,
        email: user.email,
      });

      const refreshToken = this.jwt.generateRefreshToken({ _id: user.id });

      user.refreshToken = refreshToken;

      await user.save();

      return this.apiResponse
        .auth(
          "Login successful",
          {
            accessToken,
            refreshToken,
            tokenType: "Bearer",
            expiresIn: this.jwt.accessTokenExpiry,
          },
          {
            _id: user._id,
            email: user.email,
            fullName: user.fullName,
            image: user.image || "",
            phone: user.phone || "+237 --- --- ---",
            provider: user.provider,
          }
        )
        .send(res, 200);
    }
  );

  changePassword = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const userId = (req.user as any)?._id;

      const { currentPassword, newPassword } = req.body;

      if (currentPassword === newPassword) {
        return this.apiResponse
          .error("Don't you dare with me again")
          .send(res, 400);
      }

      if (!currentPassword || !newPassword) {
        return this.apiResponse.error("All fields are required").send(res, 400);
      }

      const user = await User.findById(userId);
      if (!user) return this.apiResponse.error("User not found").send(res, 404);

      const isMatch = await user.comparePassword(currentPassword);

      if (!isMatch) {
        return this.apiResponse
          .error("Current password is incorrect")
          .send(res, 400);
      }

      user.password = newPassword;
      await user.save();

      return this.apiResponse
        .success("Password changed successfully")
        .send(res, 200);
    }
  );

  authenticate = this.asyncHandler.handler(
    (req: Request, res: Response, next: NextFunction) => {
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(" ")[1];

      if (!token) {
        return this.apiResponse.error("Unauthorised!").send(res, 401);
      }

      const result = this.jwt.verifyAccessToken(token);

      if (!result.valid) {
        const statusCode = result.expired ? 401 : 403; // 401 = Unauthorized (expired)
        return this.apiResponse.error(
          result.expired
            ? "Please signin or create an account"
            : "You don't have access to this feature"
        );
      }

      // Attach user info to request
      req.user = result.payload;

      next();
    }
  );

  refreshToken = this.asyncHandler.handler(
    async (req: Request, res: Response) => {
      const { refreshToken } = req.body;

      // console.log("Refresh token request received:", refreshToken);

      if (!refreshToken) {
        return this.apiResponse.error("Refresh token required").send(res, 401);
      }

      const result = this.jwt.verifyRefreshToken(refreshToken);

      if (!result.valid || !result.payload) {
        return this.apiResponse
          .error(
            result.expired ? "Refresh token expired" : "Invalid refresh token"
          )
          .send(res, 403);
      }

      // Notice: payload has { id, jti }
      const user = await User.findById(result.payload._id);
      if (!user) {
        return this.apiResponse.error("User not found").send(res, 404);
      }

      const newAccessToken = this.jwt.generateAccessToken({
        _id: user.id,
        email: user.email,
      });

      const newRefreshToken = this.jwt.generateRefreshToken({ _id: user.id });

      return this.apiResponse
        .success("Token refreshed successfully", {
          tokens: {
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            tokenType: "Bearer",
            expiresIn: "1m",
          },
          user: {
            _id: user._id,
            email: user.email,
            fullName: user.fullName,
            image: user.image || "",
            phone: user.phone || "",
          },
        })
        .send(res, 200);
    }
  );

  getUserId = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(" ")[1];

      if (!token) return next();

      const result = this.jwt.verifyAccessToken(token);

      if (result.valid) {
        req.user = result.payload;
      }

      next();
    }
  );

  checkPropertyAccess = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      if (!req.user) {
        return this.apiResponse.error("User not authenticated").send(res, 401);
      }

      const userId = (req.user as any)?._id;
      const propertyId = req.query._id as string;
      const now = new Date();

      const user = await User.findById(userId);
      if (!user) return this.apiResponse.error("User not found").send(res, 404);

      // 1. Check if property is uploaded by user
      if (user.uploadedProperties.some((p) => p.toString() === propertyId)) {
        return next();
      }

      // 2. Check accessedProperties in non-expired tokens
      const tokens = await Token.find({
        userId,
        isExpired: false,
        expiresAt: { $gt: now },
      });

      const tokenWithProperty = tokens.find((token) =>
        token.accessedProperties.some((ap) => ap.propertyId === propertyId)
      );

      if (tokenWithProperty) {
        return next();
      }

      // 3. Find a token package with available usage
      const availableToken = tokens.find(
        (token) => token.quantity - token.used > 0
      );

      if (!availableToken) {
        return this.apiResponse
          .error("No available token to access this property")
          .send(res, 403);
      }

      // 4. Consume the token
      availableToken.used += 1;
      availableToken.accessedProperties.push({
        _id: new Types.ObjectId().toString(),
        propertyId,
        accessedAt: now,
      });

      await availableToken.save();

      next(); // Access granted
    }
  );
}
