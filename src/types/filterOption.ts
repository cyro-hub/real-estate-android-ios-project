export interface FilterOptions {
  search: string;
  location?: { town: string };
  type?: string;
  rentAmount?: number;
  page: number;
  limit: number;
}
