package com.fullship.hBAF.global.config;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.BufferingClientHttpRequestFactory;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.web.client.RestTemplate;

@Configuration
public class RestTemplateConfig {

  @Bean
  public RestTemplate restTemplate(
      RestTemplateBuilder restTemplateBuilder) {
    return restTemplateBuilder.requestFactory(
            () -> new BufferingClientHttpRequestFactory(new SimpleClientHttpRequestFactory()))
        .setConnectTimeout(
            Duration.ofMillis(10000)) // connection-timeout
        .setReadTimeout(Duration.ofMillis(10000)) // read-timeout
        .additionalMessageConverters(new StringHttpMessageConverter(Charset.forName("UTF-8")))
        .build();
  }
}


