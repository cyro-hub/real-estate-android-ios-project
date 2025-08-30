import { injectable } from "tsyringe";
import { Services } from "./services";
import { Property, PropertyDocument } from "../models/property";
import { CreatePropertyDto } from "../dtos/property";
import { User } from "../models/user";
import mongoose, { Types } from "mongoose";
import TransactionManager from "./utils/transactionManagerService";
import { TokenServices } from "./tokenService";
import { Token } from "../models/token";

@injectable()
export class PropertyServices extends Services<PropertyDocument> {
  constructor(
    private tokenService: TokenServices,
    private transactionManagerService: TransactionManager
  ) {
    super(Property);
  }

  public createProperty = async (
    args: CreatePropertyDto,
    userId: string
  ): Promise<PropertyDocument> => {
    return this.transactionManagerService.withTransaction(async () => {
      await this.validateInput(CreatePropertyDto, args);

      const session = this.transactionManagerService.session;

      const user = await User.findById(userId).session(session);
      if (!user) throw new Error("User not found");

      // Create property
      const createdProperty = await this.model.create([args], { session });

      user.uploadedProperties.push(createdProperty[0]._id as Types.ObjectId);

      await user.save({ session });

      // Return the newly created property
      return createdProperty[0];
    });
  };

  public updateProperty = async (
    _id: string,
    args: CreatePropertyDto
  ): Promise<PropertyDocument | null> => {
    this.validateObjectId(_id);

    const updatedProperty = await this.model.findByIdAndUpdate(_id, args, {
      new: true,
      runValidators: true,
    });

    return updatedProperty;
  };

  public getProperty = async (_id: string, userId: string) => {
    this.validateObjectId(_id);

    const propertyId = new mongoose.Types.ObjectId(_id);

    // First fetch property
    const property = await Property.findOne({
      _id: propertyId,
      status: true,
    }).lean();

    if (!property) return null;

    // Check if user is the owner
    const userIsOwner = property.userId.toString() === userId;

    // If user is owner, return full property
    if (userIsOwner) return property;

    // Check tokens for access
    const now = new Date();
    const validTokens = await Token.find({
      userId,
      isExpired: false,
      expiresAt: { $gt: now },
      "accessedProperties.propertyId": propertyId,
    }).lean();

    const hasAccess = validTokens.length > 0;

    return {
      _id: property._id,
      title: property.title,
      description: property.description,
      rentAmount: property.rentAmount,
      images: property.images,
      createdAt: property.createdAt,
      userId: property.userId,
      videos: property.videos,
      type: property.type,
      floorLevel: property.floorLevel,
      size: property.size,
      currency: property.currency,
      paymentFrequency: property.paymentFrequency,
      securityDeposit: property.securityDeposit,
      amenities: property.amenities,
      houseRules: property.houseRules,
      viewCount: property.viewCount,
      contact: hasAccess ? property.contact : undefined,
      location: hasAccess ? property.location : undefined,
    };
  };

  public getOwnersProperties = async ({
    userId,
    page,
    limit,
    from,
    to,
    type,
    status,
  }: {
    userId: string;
    page: number;
    limit: number;
    from?: string; // or Date
    to?: string; // or Date
    type?: string;
    status?: boolean;
  }) => {
    this.validateObjectId(userId);

    const skip = (page - 1) * limit;

    // Build filter dynamically
    const filter: any = { userId };

    if (from || to) {
      filter.createdAt = {};
      if (from) filter.createdAt.$gte = new Date(from);
      if (to) filter.createdAt.$lte = new Date(to);
    }

    if (type) filter.type = type;
    if (status !== undefined) filter.status = status;

    const [properties, total] = await Promise.all([
      this.model
        .find(filter)
        .select({
          title: 1,
          description: 1,
          rentAmount: 1,
          location: 1,
          contact: 1,
          images: { $slice: 1 },
          status: 1,
          type: 1,
          createdAt: 1,
        })
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 }),

      this.model.countDocuments(filter),
    ]);
    return {
      data: properties,
      pagination: {
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        total,
      },
    };
  };

  public givePropertyAccess = async (_id: string) => {
    this.validateObjectId(_id);

    const property = await this.model
      .findOne({ _id, status: true })
      .select("contact location");

    return property;
  };

  public searchPropertiesWithFilters = async (query: {
    page?: number;
    limit?: number;
    location?: string;
    type?: string;
    maxRent?: number;
    search?: string;
    toilet?: "private" | "shared";
    bathroom?: "private" | "shared";
    kitchen?: "private" | "shared";
    waterAvailable?: boolean;
    electricity?: boolean;
    parking?: boolean;
    userId?: string;
  }) => {
    const {
      page = 1,
      limit = 10,
      location,
      type,
      maxRent,
      search,
      toilet,
      bathroom,
      kitchen,
      waterAvailable,
      electricity,
      parking,
      userId,
    } = query;

    const filters: any = { status: true };

    if (search) {
      filters.$or = [
        { title: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
      ];
    }

    if (location)
      filters["location.town"] = { $regex: location, $options: "i" };
    if (type) filters.type = type;
    if (maxRent) filters.rentAmount = { $lte: maxRent };
    if (toilet) filters["amenities.toilet"] = toilet;
    if (bathroom) filters["amenities.bathroom"] = bathroom;
    if (kitchen) filters["amenities.kitchen"] = kitchen;
    if (waterAvailable !== undefined)
      filters["amenities.waterAvailable"] = waterAvailable;
    if (electricity !== undefined)
      filters["amenities.electricity"] = electricity;
    if (parking !== undefined) filters["amenities.parking"] = parking;

    // --- Step 1: Get user token access from Token collection ---
    let accessedIds: string[] = [];
    if (userId) {
      const now = new Date();
      const tokens = await Token.find({
        userId,
        isExpired: false,
        expiresAt: { $gt: now },
      }).lean();

      accessedIds = tokens
        .flatMap((t) => t.accessedProperties || [])
        .map((p) => p.propertyId.toString());
    }

    // --- Step 2: Fetch filtered properties ---
    const properties = await Property.find(filters, {
      _id: 1,
      type: 1,
      size: 1,
      title: 1,
      description: 1,
      currency: 1,
      paymentFrequency: 1,
      rentAmount: 1,
      images: 1,
      userId: 1,
      createdAt: 1,
    })
      .skip((page - 1) * limit)
      .limit(limit)
      .sort({ createdAt: -1 })
      .lean();

    // --- Step 3: Mark hasAccess ---
    const updatedProperties = properties.map((prop: any) => ({
      ...prop,
      hasAccess:
        accessedIds.includes(prop._id.toString()) ||
        prop.userId.toString() === userId,
    }));

    const total = await Property.countDocuments(filters);

    return {
      data: updatedProperties,
      pagination: {
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        total,
      },
    };
  };

  public async searchPropertiesWithGeospatial({
    lng,
    lat,
    maxDistanceInMeters = 5000,
    searchQuery,
    propertyType,
  }: {
    lng: number;
    lat: number;
    maxDistanceInMeters?: number;
    searchQuery?: string;
    propertyType?: string;
  }) {
    if (
      typeof lng !== "number" ||
      typeof lat !== "number" ||
      isNaN(lng) ||
      isNaN(lat)
    ) {
      throw new Error("Invalid longitude or latitude");
    }

    const pipeline: any[] = [
      {
        $geoNear: {
          near: { type: "Point", coordinates: [lng, lat] },
          distanceField: "dist.calculated",
          maxDistance: maxDistanceInMeters,
          spherical: true,
        },
      },
    ];

    const matchConditions: any[] = [];

    // Add search query conditions if provided
    if (searchQuery && searchQuery.trim() !== "") {
      matchConditions.push({
        $or: [
          { title: { $regex: searchQuery, $options: "i" } },
          { description: { $regex: searchQuery, $options: "i" } },
        ],
      });
    }

    // Add property type condition if provided
    if (propertyType && propertyType.trim() !== "") {
      matchConditions.push({
        type: { $regex: `^${propertyType}$`, $options: "i" },
      });
    }

    // Push $match only if we have at least one condition
    if (matchConditions.length > 0) {
      pipeline.push({
        $match:
          matchConditions.length === 1
            ? matchConditions[0]
            : { $and: matchConditions },
      });
    }

    pipeline.push({
      $project: {
        _id: 1,
        title: 1,
        type: 1,
        description: 1,
        location: {
          coordinates: 1,
          street: "$location.street",
          landmark: "$location.landmark",
        },
      },
    });

    const results = await this.model.aggregate(pipeline);

    return results;
  }

  public async getUserTokenProperties(userId: string): Promise<
    {
      propertyId: string;
      tokenPackageId: string;
      title?: string;
      image?: string;
      price?: number;
      landmark?: string;
      town?: string;
      expiresIn: number;
      isExpired: boolean;
    }[]
  > {
    this.validateObjectId(userId);

    const tokenSummary = await this.tokenService.getTokenPropertiesSummary(
      userId
    );

    if (!tokenSummary.length) return [];

    const tokenMap = new Map<
      string,
      { expiryIn: number; isExpired: boolean; tokenPackageId: string }
    >();

    tokenSummary.forEach((t) => {
      if (!t.propertyId || !t.tokenPackageId) return;
      tokenMap.set(t.propertyId.toString(), {
        expiryIn: t.expiryIn,
        isExpired: t.isExpired,
        tokenPackageId: t.tokenPackageId,
      });
    });

    const properties = await this.model
      .find(
        { _id: { $in: Array.from(tokenMap.keys()) } },
        { title: 1, images: 1, rentAmount: 1, location: 1, currency: 1 }
      )
      .lean();

    return properties.map((prop) => {
      const token = tokenMap.get(prop._id.toString());
      return {
        propertyId: prop._id.toString(),
        tokenPackageId: token?.tokenPackageId ?? "",
        title: prop.title,
        image: prop.images?.[0] ?? "",
        rentAmount: prop.rentAmount,
        currency: prop.currency,
        landmark: prop.location?.landmark,
        town: prop.location?.town,
        expiresIn: token?.expiryIn ?? 0,
        isExpired: token?.isExpired ?? true,
      };
    });
  }

  public getUniqueTowns = async () => {
    const towns: string[] = await this.model.distinct("location.town");

    return towns;
  };

  public getFavouriteProperties = async (_ids: string[]) => {
    if (!_ids || !Array.isArray(_ids)) {
      return [];
    }

    const properties = await this.model.aggregate([
      {
        $match: {
          _id: { $in: _ids.map((id) => new mongoose.Types.ObjectId(id)) },
        },
      },
      {
        $project: {
          _id: 1,
          image: { $arrayElemAt: ["$images", 0] }, // first image
          title: 1,
          town: "$location.town",
          quarter: "$location.quarter",
          rentAmount: 1,
          currency: 1,
          paymentFrequency: 1,
        },
      },
    ]);

    return properties; // already in the desired shape
  };
}
