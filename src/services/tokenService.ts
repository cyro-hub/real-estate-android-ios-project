import { injectable } from "tsyringe";
import { Services } from "./services";
import { Types } from "mongoose";
import { Token, TokenDocument } from "../models/token";

@injectable()
export class TokenServices extends Services<TokenDocument> {
  constructor() {
    super(Token);
  }

  async addToken(
    userId: string,
    quantity: number,
    durationHours: number
  ): Promise<TokenDocument> {
    const now = new Date();
    const expiresAt = new Date(now.getTime() + durationHours * 60 * 60 * 1000);

    const newToken: Partial<TokenDocument> = {
      userId,
      quantity,
      used: 0,
      accessedProperties: [],
      purchasedAt: now,
      expiresAt,
      isExpired: false,
    };

    const createdToken = await this.model.create(newToken);

    return createdToken;
  }

  async setExpiredTokenPackages(userId: string) {
    this.validateObjectId(userId);

    const result = await this.model.updateMany(
      {
        userId,
        expiresAt: { $lte: new Date() },
        isExpired: false,
      },
      {
        $set: { isExpired: true },
      }
    );

    return result;
  }

  getTokenPropertiesSummary = async (userId: string) => {
    this.validateObjectId(userId);

    const now = new Date();

    const tokenPackages: TokenDocument[] = await Token.find({ userId });

    const tokenProperties = tokenPackages.flatMap((pkg) =>
      pkg.accessedProperties.map((prop) => ({
        propertyId: prop.propertyId,
        tokenPackageId: pkg._id,
        expiryIn: Math.max(
          0,
          (new Date(pkg.expiresAt).getTime() - now.getTime()) / (1000 * 60 * 60) // in hours
        ),
        isExpired: pkg.isExpired || new Date(pkg.expiresAt) <= now,
      }))
    );

    return tokenProperties;
  };
}
