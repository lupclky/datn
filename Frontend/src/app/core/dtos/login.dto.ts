export interface loginDetailDto {
    message : string,
    token : string,
    is_new_user?: boolean,
    google_email?: string,
    google_name?: string,
}