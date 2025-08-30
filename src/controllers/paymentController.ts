import { inject, injectable } from "tsyringe";
import AsyncHandler from "../services/utils/asyncHandlerService";
import { NextFunction, Request, Response } from "express-serve-static-core";
import ApiResponse from "../services/utils/apiResponseService";
import { MtnMoMoService } from "../services/payments/mtnMoMoService";

@injectable()
export default class PaymentController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private readonly mtnMoMoService: MtnMoMoService,
    private apiResponse: ApiResponse
  ) {}

  requestToPayMtn = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const userId = (req.user as any)?._id;

      const response = await this.mtnMoMoService.requestToPay(
        "250",
        "+237677777771",
        "Payment for token"
      );

      return this.apiResponse
        .success("token created successfully", {})
        .send(res);
    }
  );
}
