export interface ProductUploadReq {
    name : string,
    price : number,
    category_id : number,
    description: string,
    discount: number,
    quantity: number,
    add_quantity?: boolean, // If true, add quantity to existing; if false or undefined, replace quantity
    featureIds?: number[],
    thumbnail?: string, // Thumbnail image URL
}