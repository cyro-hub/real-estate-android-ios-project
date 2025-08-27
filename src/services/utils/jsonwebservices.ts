import jwt, { JwtPayload, SignOptions } from "jsonwebtoken";
import { injectable } from "tsyringe";

interface AccessTokenPayload {
  _id: string;
  email: string;
}

interface RefreshTokenPayload {
  _id: string;
  jti: string; // unique ID for tracking/revocation
}

interface VerifyResult<T> {
  valid: boolean;
  expired: boolean;
  payload?: T;
  error?: string;
}

@injectable()
export default class Jwt {
  private accessSecret: string;
  private refreshSecret: string;

  constructor() {
    if (!process.env.JWT_ACCESS_SECRET || !process.env.JWT_REFRESH_SECRET) {
      throw new Error("JWT secrets must be defined in environment variables");
    }

    this.accessSecret = process.env.JWT_ACCESS_SECRET?.toString();
    this.refreshSecret = process.env.JWT_REFRESH_SECRET?.toString();
  }

  public generateAccessToken(payload: AccessTokenPayload): string {
    const options: SignOptions = {
      expiresIn: 15 * 60,
      algorithm: "HS256",
    };

    return jwt.sign(payload, this.accessSecret, options);
  }

  public generateRefreshToken(payload: { _id: string }): string {
    const jti = crypto.randomUUID(); // unique ID for revocation tracking
    const tokenPayload: RefreshTokenPayload = { _id: payload._id, jti };

    const options: SignOptions = {
      expiresIn: 7 * 24 * 60,
      algorithm: "HS256",
    };

    return jwt.sign(tokenPayload, this.refreshSecret, options);
  }

  public verifyAccessToken(token: string): VerifyResult<AccessTokenPayload> {
    try {
      const decoded = jwt.verify(token, this.accessSecret, {
        algorithms: ["HS256"],
      }) as JwtPayload & AccessTokenPayload;

      return { valid: true, expired: false, payload: decoded };
    } catch (error: any) {
      return {
        valid: false,
        expired: error?.name === "TokenExpiredError",
        error: error.message,
      };
    }
  }

  public verifyRefreshToken(token: string): VerifyResult<RefreshTokenPayload> {
    try {
      const decoded = jwt.verify(token, this.refreshSecret, {
        algorithms: ["HS256"],
      }) as JwtPayload & RefreshTokenPayload;

      return { valid: true, expired: false, payload: decoded };
    } catch (error: any) {
      return {
        valid: false,
        expired: error?.name === "TokenExpiredError",
        error: error.message,
      };
    }
  }
}
