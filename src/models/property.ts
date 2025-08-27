import mongoose, { Schema, Document, Model, Types } from "mongoose";

// === Types ===
type PropertyType =
  | "apartment"
  | "house"
  | "studio"
  | "office"
  | "shop"
  | "land"
  | "duplex"
  | "villa";
type ToiletType = "private" | "shared";
type BathroomType = "private" | "shared";
type kitchenType = "private" | "shared";
type meterType = "prepaid" | "postpaid";

// GeoJSON Point interface for location
interface GeoJSONPoint {
  type: "Point";
  coordinates: [number, number]; // [lng, lat]
  town: string;
  quarter: string;
  street: string;
  landmark: string;
}

interface Amenities {
  toilet: ToiletType;
  bathroom: BathroomType;
  kitchen: kitchenType;
  furnished: boolean;
  waterAvailable: boolean;
  electricity: boolean;
  meterType: meterType;
  internet: boolean;
  parking: boolean;
  balcony: boolean;
  ceilingFan: boolean;
  tiledFloor: boolean;
}

interface HouseRules {
  smokingAllowed: boolean;
  petsAllowed: boolean;
  quietHours: string;
  visitorsAllowed: boolean;
}

interface Contact {
  phone: string;
  whatsapp: string;
  agentName: string;
}

// Main Property document interface
export interface PropertyDocument extends Document {
  userId: Types.ObjectId;
  title: string;
  description: string;
  images: string[];
  videos: string[];
  location: GeoJSONPoint; // GeoJSON point for geospatial queries
  type: PropertyType;
  floorLevel: number;
  size: string;
  rentAmount: number;
  currency: string;
  paymentFrequency: string;
  securityDeposit: number;
  amenities: Amenities;
  houseRules: HouseRules;
  contact: Contact;
  viewCount: number;
  status: boolean;
  createdAt: Date;
  expiresAt: Date;
}

// === Schemas ===

// GeoJSON Point Schema (no _id for subdocument)
const GeoJSONPointSchema = new Schema<GeoJSONPoint>(
  {
    type: {
      type: String,
      enum: ["Point"],
      required: true,
      default: "Point",
    },
    coordinates: {
      type: [Number],
      required: true,
      validate: {
        validator: (arr: number[]) => arr.length === 2,
        message: "Coordinates must be an array of two numbers [lng, lat]",
      },
    },
    town: { type: String },
    quarter: { type: String },
    street: { type: String },
    landmark: { type: String },
  },
  { _id: false }
);

const AmenitiesSchema = new Schema<Amenities>({
  toilet: { type: String, enum: ["private", "shared"], required: true },
  bathroom: {
    type: String,
    enum: ["private", "shared"],
    required: true,
  },
  kitchen: {
    type: String,
    enum: ["private", "shared"],
    required: true,
  },
  meterType: { type: String, enum: ["prepaid", "postpaid"], required: true },
  furnished: { type: Boolean, required: true },
  waterAvailable: { type: Boolean, required: true },
  electricity: { type: Boolean, required: true },
  internet: { type: Boolean, required: true },
  parking: { type: Boolean, required: true },
  balcony: { type: Boolean, required: true },
  ceilingFan: { type: Boolean, required: true },
  tiledFloor: { type: Boolean, required: true },
});

const HouseRulesSchema = new Schema<HouseRules>({
  smokingAllowed: { type: Boolean, required: true },
  petsAllowed: { type: Boolean, required: true },
  quietHours: { type: String, required: true },
  visitorsAllowed: { type: Boolean, required: true },
});

const ContactSchema = new Schema<Contact>({
  phone: { type: String, required: true },
  whatsapp: { type: String, required: true },
  agentName: { type: String, required: true },
});

// Main Property Schema
const PropertySchema = new Schema<PropertyDocument>({
  userId: {
    type: Schema.Types.ObjectId,
    required: true,
    ref: "User",
  },
  title: { type: String, required: true },
  description: { type: String, required: true },
  images: { type: [String] },
  videos: { type: [String] },
  location: { type: GeoJSONPointSchema, required: true },
  type: {
    type: String,
    required: true,
    enum: [
      "apartment",
      "house",
      "studio",
      "office",
      "shop",
      "land",
      "duplex",
      "villa",
    ], // ✅ only allowed values
  },
  floorLevel: { type: Number, required: true },
  size: { type: String, required: true },
  rentAmount: { type: Number, required: true },
  currency: { type: String, required: true },
  paymentFrequency: { type: String, required: true },
  securityDeposit: { type: Number, required: true },
  amenities: { type: AmenitiesSchema, required: true },
  houseRules: { type: HouseRulesSchema, required: true },
  contact: { type: ContactSchema, required: true },
  viewCount: { type: Number, default: 0 },
  status: { type: Boolean, default: false },
  createdAt: { type: Date, required: true },
  expiresAt: { type: Date, required: true },
});

// Create geospatial 2dsphere index on location
PropertySchema.index({ location: "2dsphere" });

// Export the model (reuse existing if any)
export const Property: Model<PropertyDocument> =
  mongoose.models.Property ||
  mongoose.model<PropertyDocument>("Property", PropertySchema);
