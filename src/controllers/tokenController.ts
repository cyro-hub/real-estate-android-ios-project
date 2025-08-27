import { inject, injectable } from "tsyringe";
import AsyncHandler from "../services/utils/asyncHandlerService";
import { NextFunction, Request, Response } from "express-serve-static-core";
import { TokenServices } from "../services/tokenService";
import ApiResponse from "../services/utils/apiResponseService";

@injectable()
export default class TokenController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private tokenService: TokenServices,
    private apiResponse: ApiResponse
  ) {}

  addToken = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const userId = (req.user as any)?._id;

      const { hours, quantity } = req.body;

      const newToken = await this.tokenService.addToken(
        userId,
        quantity,
        hours
      );

      return this.apiResponse
        .success("token created successfully", newToken)
        .send(res);
    }
  );
}
