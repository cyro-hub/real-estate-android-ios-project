import {
  IsString,
  IsNumber,
  IsBoolean,
  IsOptional,
  IsArray,
  ValidateNested,
  IsEnum,
  IsDateString,
  Min,
  ArrayNotEmpty,
  ValidateIf,
} from "class-validator";
import { Type } from "class-transformer";

class LocationDto {
  @IsString()
  type!: "Point"; // GeoJSON 'type' fixed to "Point"

  @IsString()
  town!: string;

  @IsString()
  quarter!: string;

  @IsString()
  street!: string;

  @IsString()
  landmark!: string;
}

class HouseRulesDto {
  @IsBoolean()
  smokingAllowed!: boolean;

  @IsBoolean()
  petsAllowed!: boolean;

  @IsString()
  quietHours!: string;

  @IsBoolean()
  visitorsAllowed!: boolean;
}

class ContactDto {
  @IsString()
  phone!: string;

  @IsString()
  whatsapp!: string;

  @IsString()
  agentName!: string;
}

export class CreatePropertyDto {
  @IsString()
  title!: string;

  @IsString()
  description!: string;

  @ValidateNested()
  @Type(() => LocationDto)
  location!: LocationDto;

  @IsString()
  type!: string;

  @IsNumber()
  floorLevel!: number;

  @IsString()
  size!: string;

  @IsNumber()
  @Min(0)
  rentAmount!: number;

  @IsString()
  currency!: string;

  @IsString()
  paymentFrequency!: string;

  @IsNumber()
  @Min(0)
  securityDeposit!: number;

  @ValidateNested()
  @Type(() => HouseRulesDto)
  houseRules!: HouseRulesDto;

  @ValidateNested()
  @Type(() => ContactDto)
  contact!: ContactDto;

  @IsNumber()
  @IsOptional()
  viewCount?: number;

  @IsDateString()
  createdAt!: string;

  @IsDateString()
  expiresAt!: string;
}
