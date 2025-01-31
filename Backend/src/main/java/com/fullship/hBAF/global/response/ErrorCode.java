package com.fullship.hBAF.global.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ErrorCode {
    /* 예시 필요한 것 추가해서 사용*/
    TEST_NOT_FOUND(HttpStatus.NOT_FOUND, "전달할 메시지"),

    /* S3 업로드 실패 */
    FAIL_TO_UPLOAD_S3(HttpStatus.BAD_GATEWAY, "S3 서버의 업로드를 실패했습니다."),

    /* JWT Token Error */
    EXPIRED_TOKEN(HttpStatus.UNAUTHORIZED, "만료된 토큰"),
    INVALID_TOKEN(HttpStatus.FORBIDDEN, "잘못된 토큰"),
    TOKEN_NOT_FOUND(HttpStatus.NOT_FOUND, "토큰을 찾을 수 없습니다."),

    /* TMapApi 요청 실패 */
    NO_AVAILABLE_API(HttpStatus.BAD_REQUEST, "API 요청에 실패하였습니다."),

    /* JSON Parsing 실패 */
    JSON_PARSE_IMPOSSIBLE(HttpStatus.BAD_GATEWAY, "API Parsing 중 오류가 발생했습니다."),

    /* 엑셀 파일 입력 실패 */
    ABNORMAL_FILE_READ(HttpStatus.BAD_REQUEST, "EXEL 파일을 읽던 중 오류가 발생했습니다."),

    REQUEST_NOT_FOUND(HttpStatus.BAD_REQUEST, "요청 변수를 확인해주십시오."),

    /* entity 존재하지 않음 */
    ENTITIY_NOT_FOUND(HttpStatus.NOT_FOUND, "요청한 정보를 찾을 수 없습니다."),

    /* entity 이미 존재 */
    ENTITIY_ALREADY_EXIST(HttpStatus.CONFLICT, "이미 존재하는 정보입니다."),

    /* H3 index missing */
    H3_INDEX_NOT_FOUND(HttpStatus.NOT_FOUND, "h3 index를 찾을 수 없습니다."),

    /* URI */
    URI_SYNTAX_ERROR(HttpStatus.BAD_GATEWAY, "외부 API 호출 중 오류가 발생했습니다."),

    FAIL_CALCULATE_COST(HttpStatus.BAD_REQUEST, "택시 요금 계산 중 오류가 발생했습니다.");

    private final HttpStatus httpStatus;

    private final String message;
}
