import { injectable } from "tsyringe";
import { Payment, PaymentDocument } from "../../models/payment";
import { Services } from "../services";
import axios, { AxiosRequestConfig } from "axios";
import { v4 as uuidv4 } from "uuid";
import * as https from "https";

@injectable()
export class MtnMoMoService extends Services<PaymentDocument> {
  constructor() {
    super(Payment);
  }

  public generateAccessToken = async (): Promise<string> => {
    const xReferenceId = uuidv4();

    const credentials = `${process.env.MTN_USER_REF_ID?.toString()}:${process.env.MTN_API_KEY?.toString()}`;
    const authHeaderValue = Buffer.from(credentials).toString("base64");

    const response = await axios.request(
      this._config("POST", "token/", `Basic ${authHeaderValue}`, xReferenceId)
    );

    return response.data.access_token;
  };

  public requestToPay = async (
    amount: string,
    phone: string,
    payerMessage: string
  ) => {
    const xReferenceId = uuidv4();

    const authToken = await this.generateAccessToken();
    const authHeaderValue = `Bearer ${authToken}`;

    const data = JSON.stringify({
      amount,
      currency: "EUR",
      externalId: "123",
      payer: {
        partyIdType: "MSISDN",
        partyId: phone,
      },
      payerMessage,
      payeeNote: "Receiving payment for token to view properties",
    });

    await axios.request(
      this._config(
        "POST",
        "v1_0/requesttopay",
        authHeaderValue,
        xReferenceId,
        data
      )
    );

    const response = await axios.request(
      this._config(
        "GET",
        `v1_0/requesttopay/${xReferenceId}`,
        authHeaderValue,
        xReferenceId
      )
    );

    console.log("MTN Payment request initiated successfully.", response.data);
  };

  private _config(
    method: string,
    endpoint: string,
    authHeaderValue: string,
    xReferenceId: string,
    body?: any
  ): AxiosRequestConfig {
    const xTargetEnvironment =
      process.env.NODE_ENV?.toString() === "production"
        ? "production"
        : "sandbox";

    // Create a new HTTPS agent that ignores SSL certificate errors.
    // This is ONLY for development and sandbox environments.
    // DO NOT use this in production.
    const agent = new https.Agent({
      rejectUnauthorized: false,
    });

    return {
      method,
      url: `${process.env.MTN_API_URL?.toString()}/${endpoint}`,
      httpsAgent: agent,
      headers: {
        "Ocp-Apim-Subscription-Key": process.env.MTN_SECONDARY_KEY?.toString(),
        Authorization: authHeaderValue,
        "X-Reference-Id": xReferenceId,
        "X-Target-Environment": xTargetEnvironment,
        "Content-Type": "application/json",
      },
      data: body,
    };
  }
}
