import { injectable } from "tsyringe";
import AsyncHandler from "../services/utils/asyncHandlerService";
import { NextFunction, Request, Response } from "express-serve-static-core";
import { PropertyServices } from "../services/propertyService";
import ApiResponse from "../services/utils/apiResponseService";
import { parseBoolean } from "../services/utils/utilityService";

@injectable()
export default class PropertyController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private propertyService: PropertyServices,
    private apiResponse: ApiResponse
  ) {}

  createProperty = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const userId = (req.user as any)?._id;

      const newProperty = { ...req.body, userId };

      const property = await this.propertyService.createProperty(
        newProperty,
        userId
      );

      return this.apiResponse
        .success("Property created successfully", property)
        .send(res);
    }
  );

  updateProperty = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      // console.log(req.body);
      const property = await this.propertyService.updateProperty(
        req.params._id as string,
        req.body
      );
      return this.apiResponse
        .success("Property updated successfully", property)
        .send(res);
    }
  );

  getProperty = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const userId = (req.user as any)?._id;

      const property = await this.propertyService.getProperty(
        req.query._id as string,
        userId
      );

      return this.apiResponse
        .success("Property fetched successfully", property)
        .send(res, 200);
    }
  );

  getOwnersProperties = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const { type, status, to, from, limit, page } = req.query;

      const userId = (req.user as any)?._id;

      // Parse boolean status
      const parsedStatus = status ? parseBoolean(status as string) : undefined;

      // Parse from/to dates
      const parsedFrom = from ? from : undefined;
      const parsedTo = to ? to : undefined;

      // Build query object
      const query: any = {
        userId,
        page: Number(page) || 1,
        limit: Number(limit) || 10,
      };

      if (parsedStatus !== null) query.status = parsedStatus;
      if (type) query.type = type;
      if (parsedFrom) query.from = parsedFrom;
      if (parsedTo) query.to = parsedTo;

      const properties = await this.propertyService.getOwnersProperties(query);

      return this.apiResponse
        .success(
          "Properties fetched successfully",
          properties?.data,
          properties?.pagination
        )
        .send(res);
    }
  );

  givePropertyAccess = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const property = await this.propertyService.givePropertyAccess(
        req.query._id as string
      );
      return this.apiResponse
        .success("Property access fetched successfully", property)
        .send(res, 200);
    }
  );

  searchPropertiesWithFilters = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const limit = Number(req.query.limit);

      const userId = (req.user as any)?._id;

      const query = {
        ...req.query,
        limit: limit || 10,
        userId,
      };

      const results = await this.propertyService.searchPropertiesWithFilters(
        query
      );

      return this.apiResponse
        .success(
          "Properties fetched successfully",
          results?.data,
          results?.pagination
        )
        .send(res);
    }
  );

  searchPropertiesWithGeospatial = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const { lon, lat, search, propertyType } = req.query;

      const longitude = lon ? parseFloat(lon as string) : undefined;
      const latitude = lat ? parseFloat(lat as string) : undefined;

      if (!longitude || !latitude || isNaN(longitude) || isNaN(latitude)) {
        return this.apiResponse
          .error("Longitude and latitude are required and must be numbers")
          .send(res, 400);
      }

      const results = await this.propertyService.searchPropertiesWithGeospatial(
        {
          lng: longitude,
          lat: latitude,
          searchQuery: search as string | undefined,
          propertyType: propertyType as string | undefined,
        }
      );

      return this.apiResponse
        .success("Properties fetched successfully", results)
        .send(res);
    }
  );

  getUserTokenProperties = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const userId = (req.user as any)?._id;

      const userTokenProperties =
        await this.propertyService.getUserTokenProperties(userId);

      return this.apiResponse
        .success("Property fetched successfully", userTokenProperties)
        .send(res, 200);
    }
  );

  getUniqueTowns = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const towns = await this.propertyService.getUniqueTowns();

      return this.apiResponse
        .success("Towns fetched successfully", towns)
        .send(res, 200);
    }
  );

  getFavouriteProperties = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const favProperties = await this.propertyService.getFavouriteProperties(
        req.body.favIds
      );

      return this.apiResponse
        .success("favProperties fetched successfully", favProperties)
        .send(res, 200);
    }
  );
}
