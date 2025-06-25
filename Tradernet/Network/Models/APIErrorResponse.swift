struct APIErrorResponse: Decodable {
    let code: Int
    let error: String
    let errMsg: String
}
