install.packages('httr')
install.packages('rvest')
library(httr)
library(rvest)
url = 'https://movie.daum.net/ranking/reservation'
movie = GET(url)
print(movie)
movie_html = read_html(movie)
print(movie_html)
movie_title = movie_html %>%
  html_nodes('.tit_item') %>%
  html_nodes('.link_txt')
movie_grade = movie_html %>%
  html_nodes('.txt_grade')
movie_rate = movie_html %>%
  html_nodes('.txt_info') %>%
  html_nodes('.txt_num')
movie_num2 = movie_html %>%
  html_nodes('.info_txt') %>%
  html_nodes('.txt_num')
movie_rate_text = movie_rate %>%  html_text()
movie_num1_text = movie_num2 %>%  html_text()
movie_title_text = movie_title %>%  html_text()
movie_grade_text = movie_grade %>%
  html_text()
movie_df = data.frame(
  '제목' = movie_title_text,
  '평점' = movie_grade_text,
  '예매율' = movie_num1_text,
  '개봉' = movie_rate_text
)
print(movie_df)
