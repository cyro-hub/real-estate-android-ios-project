import mongoose, { Document, Schema, model, Types } from "mongoose";
import bcrypt from "bcryptjs";

export interface UserDocument extends Document {
  _id: string;
  email: string;
  password: string;
  fullName: string;
  uploadedProperties: Types.ObjectId[];
  isActive: boolean;
  provider: "google" | "local";
  googleId?: string;
  image?: string;
  refreshToken?: string;
  isVerified: boolean;
  comparePassword(password: string): Promise<boolean>;
  createdAt: Date;
  updatedAt: Date;
  phone?: string;
}

const userSchema = new Schema<UserDocument>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
    },
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
    refreshToken: {
      type: String,
    },
    phone: {
      type: String,
    },
    image: {
      type: String,
    },
    googleId: {
      type: String,
    },
    uploadedProperties: [
      {
        type: Schema.Types.ObjectId,
        ref: "Property", // assuming you have a Property model
      },
    ],
    isActive: {
      type: Boolean,
      default: true,
    },
    isVerified: {
      type: Boolean,
      default: true,
    },
    provider: { type: String, enum: ["google", "local"], required: true },
  },
  {
    timestamps: true,
  }
);

userSchema.methods.comparePassword = function (
  password: string
): Promise<boolean> {
  return bcrypt.compare(password, this.password);
};

userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

export const User = model<UserDocument>("User", userSchema);
