import { injectable } from "tsyringe";

export interface IApiResponse {
  success: boolean;
  message: string;
  data?: any;
  errors?: any;
  meta?: Record<string, any>;
}

@injectable()
export default class ApiResponse {
  private body: IApiResponse | null = null;

  success(message: string, data?: any, meta?: Record<string, any>) {
    this.body = { success: true, message, data, meta };
    return this;
  }

  error(message: string, errors?: any, meta?: Record<string, any>) {
    this.body = { success: false, message, errors, meta };
    return this;
  }

  auth(
    message: string,
    tokens: {
      accessToken: string;
      refreshToken: string;
      tokenType: string;
      expiresIn: string;
    },
    user: {
      _id: string;
      email: string;
      fullName: string;
      image?: string;
      phone?: string;
      provider?: string;
    }
  ) {
    this.body = { success: true, message, data: { tokens, user } };
    return this;
  }

  send(res: any, statusCode: number = 200) {
    return res.status(statusCode).json(this.body);
  }
}
