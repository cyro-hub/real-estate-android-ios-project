import { Schema, model, Document } from "mongoose";

export interface IParty {
  partyIdType: string;
  partyId: string;
}

const PartySchema = new Schema<IParty>(
  {
    partyIdType: {
      type: String,
      required: true,
      enum: ["MSISDN", "EMAIL", "PARTY_CODE"],
      description: "The type of the party ID (e.g., MSISDN for phone number)",
    },
    partyId: {
      type: String,
      required: true,
      description: "The party ID (e.g., a phone number or email)",
    },
  },
  { _id: false }
);

export interface IErrorReason {
  code: string;
  message: string;
}

const ErrorReasonSchema = new Schema<IErrorReason>(
  {
    code: {
      type: String,
      required: true,
      description: "The error code from the transaction.",
    },
    message: {
      type: String,
      description: "A description of the error.",
    },
  },
  { _id: false }
);

export type PaymentStatus = "PENDING" | "SUCCESSFUL" | "FAILED";

export interface PaymentDocument extends Document {
  amount: string;
  currency: string;
  financialTransactionId?: string;
  externalId: string;
  payer: IParty;
  payerMessage?: string;
  payeeNote?: string;
  status: PaymentStatus;
  reason?: IErrorReason;
  createdAt: Date;
  updatedAt: Date;
}

const PaymentSchema = new Schema<PaymentDocument>(
  {
    amount: {
      type: String,
      required: true,
      description: "Amount that will be debited from the payer account.",
    },
    currency: {
      type: String,
      required: true,
      description: "ISO4217 Currency",
    },
    financialTransactionId: {
      type: String,
      description: "Financial transaction ID from the mobile money manager.",
    },
    externalId: {
      type: String,
      required: true,
      unique: true,
      description:
        "External ID provided in the creation of the requestToPay transaction.",
    },
    payer: {
      type: PartySchema,
      required: true,
      description: "The party making the payment.",
    },
    payerMessage: {
      type: String,
      description: "Message for the payer transaction history.",
    },
    payeeNote: {
      type: String,
      description: "Message for the payee transaction history.",
    },
    status: {
      type: String,
      required: true,
      enum: ["PENDING", "SUCCESSFUL", "FAILED"],
      default: "PENDING",
    },
    reason: {
      type: ErrorReasonSchema,
      description: "Reason for failure if the transaction did not succeed.",
    },
  },
  {
    timestamps: true,
  }
);

export const Payment = model<PaymentDocument>("Payment", PaymentSchema);
