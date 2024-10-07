package com.example.demo.DTOs;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class MapFilter {
  private int map_id;
  private String map_name;
  private String username;
  private int[] wave_lengths;
  private float clear_rate_up_to;
  private String sort_by;
  private String order_by;
  private int page_number;
  private int page_size;
    @JsonCreator
    public MapFilter(@JsonProperty("map_id") int map_id,
                     @JsonProperty("map_name") String map_name,
                     @JsonProperty("username") String user_name,
                     @JsonProperty("wave_lengths") int[] wave_lengths,
                     @JsonProperty("clear_rate_up_to") float clear_rate_up_to,
                     @JsonProperty("sort_by") String sort_by,
                     @JsonProperty("order_by") String order_by,
                     @JsonProperty("page_number") int page_number,
                     @JsonProperty("page_size") int page_size) {
        this.map_id = map_id;
        this.map_name = map_name;
        this.username = user_name;
        this.wave_lengths = wave_lengths;
        this.clear_rate_up_to = clear_rate_up_to;
        this.sort_by = sort_by;
        this.order_by = order_by;
        this.page_number = page_number;
        this.page_size = page_size;
    }


}
