import mongoose, { Document, Schema, model } from "mongoose";

export interface AccessedProperty {
  _id: string;
  propertyId: string;
  accessedAt: Date;
}

export interface TokenDocument {
  _id: string;
  quantity: number;
  userId: string;
  used: number;
  accessedProperties: AccessedProperty[];
  purchasedAt: Date;
  expiresAt: Date;
  isExpired: boolean;
}

const AccessedPropertySchema = new Schema({
  propertyId: {
    type: Schema.Types.ObjectId,
    ref: "Property",
    required: true,
  },
  accessedAt: { type: Date, required: true },
});

const TokenSchema = new Schema({
  quantity: { type: Number, required: true },
  used: { type: Number, required: true, default: 0 },
  accessedProperties: [AccessedPropertySchema],
  purchasedAt: { type: Date, required: true },
  expiresAt: { type: Date, required: true },
  isExpired: { type: Boolean, required: true, default: false },
  userId: {
    type: Schema.Types.ObjectId,
    ref: "User",
  },
});

export const Token = model<TokenDocument>("Token", TokenSchema);
