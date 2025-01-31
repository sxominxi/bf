package com.fullship.hBAF.domain.review.controller.request;

import lombok.Data;
import lombok.Getter;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Data
public class ModifyReviewRequest {

    Long reviewId;
    String content;
    String lik;
    String unlik;
    List<String> img;

}
