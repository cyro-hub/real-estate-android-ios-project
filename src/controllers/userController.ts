import { injectable } from "tsyringe";
import AsyncHandler from "../services/utils/asyncHandlerService";
import { NextFunction, Request, Response } from "express-serve-static-core";
import { UserServices } from "../services/userService";
import ApiResponse from "../services/utils/apiResponseService";

@injectable()
export default class UserController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private userService: UserServices,
    private apiResponse: ApiResponse
  ) {}

  getUser = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const userId = (req.user as any)?._id;

      const user = await this.userService.getUser(userId);

      return this.apiResponse
        .success("user fetched successfully", user)
        .send(res, 200);
    }
  );

  updateUser = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const userId = (req.user as any)?._id;

      const updatedUser = await this.userService.updateUser(userId, req.body);

      return this.apiResponse
        .success("Updated user fetched successfully", updatedUser)
        .send(res, 200);
    }
  );
}
