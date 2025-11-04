package com.example.Sneakers.responses;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class NewsListResponse {
    @JsonProperty("news_list")
    private List<NewsResponse> newsList;

    @JsonProperty("total_pages")
    private int totalPages;
}

