local ngx_re = require "ngx.re"
local split = ngx_re.split

local _M = {
    humi = nil,
    data = {}
}

local data_from_excel = {
  "98,96,94,92,90,88,86,84,82,80,78,76,75,74,73,72,71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25",
  "11.7,11.4,11.1,10.7,10.4,10.1,9.7,9.4,9,8.7,8.3,7.9,7.7,7.5,7.3,7.1,6.9,6.7,6.5,6.3,6.1,5.9,5.6,5.4,5.2,5,4.7,4.5,4.2,4,3.8,3.5,3.3,3,2.7,2.5,2.2,1.9,1.6,1.3,1.1,0.8,0.5,0.1,,,,,,,,,,,,,,,,,,,",
  "12.2,11.9,11.6,11.2,10.9,10.6,10.2,9.9,9.5,9.1,8.8,8.4,8.2,8,7.8,7.6,7.4,7.2,7,6.8,6.5,6.3,6.1,5.9,5.7,5.4,5.2,5,4.7,4.5,4.2,4,3.7,3.5,3.2,2.9,2.7,2.4,2.1,1.8,1.5,1.2,0.9,0.6,0.3,,,,,,,,,,,,,,,,,,",
  "12.7,12.4,12.1,11.7,11.4,11.1,10.7,10.4,10,9.6,9.3,8.9,8.7,8.5,8.3,8.1,7.9,7.7,7.5,7.2,7,6.8,6.6,6.4,6.1,5.9,5.7,5.4,5.2,4.9,4.7,4.4,4.2,3.9,3.7,3.4,3.1,2.8,2.5,2.3,2,1.7,1.4,1,0.7,0.4,0.1,,,,,,,,,,,,,,,,",
  "13.2,12.9,12.6,12.2,11.9,11.6,11.2,10.9,10.5,10.1,9.7,9.4,9.2,9,8.8,8.6,8.4,8.1,7.9,7.7,7.5,7.3,7.1,6.8,6.6,6.4,6.1,5.9,5.7,5.4,5.2,4.9,4.6,4.4,4.1,3.8,3.6,3.3,3,2.7,2.4,2.1,1.8,1.5,1.2,0.9,0.5,0.2,,,,,,,,,,,,,,,",
  "13.7,13.4,13.1,12.7,12.4,12,11.7,11.3,11,10.6,10.2,9.8,9.6,9.4,9.2,9,8.8,8.6,8.4,8.2,8,7.8,7.5,7.3,7.1,6.8,6.6,6.4,6.1,5.9,5.6,5.4,5.1,4.9,4.6,4.3,4,3.8,3.5,3.2,2.9,2.6,2.3,2,1.6,1.3,1,0.6,0.3,,,,,,,,,,,,,,",
  "14.2,13.9,13.5,13.2,12.9,12.5,12.2,11.8,11.5,11.1,10.7,10.3,10.1,9.9,9.7,9.5,9.3,9.1,8.9,8.7,8.5,8.2,8,7.8,7.5,7.3,7.1,6.8,6.6,6.3,6.1,5.8,5.6,5.3,5,4.8,4.5,4.2,3.9,3.6,3.3,3,2.7,2.4,2.1,1.8,1.4,1.1,0.7,0.4,0,,,,,,,,,,,,",
  "14.7,14.4,14,13.7,13.4,13,12.7,12.3,12,11.6,11.2,10.8,10.6,10.4,10.2,10,9.8,9.6,9.4,9.1,8.9,8.7,8.5,8.3,8,7.8,7.5,7.3,7.1,6.8,6.6,6.3,6,5.8,5.5,5.2,5,4.7,4.4,4.1,3.8,3.5,3.2,2.9,2.5,2.2,1.9,1.5,1.2,0.8,0.4,0.1,,,,,,,,,,,",
  "15.2,14.9,14.5,14.2,13.9,13.5,13.2,12.8,12.5,12.1,11.7,11.3,11.1,10.9,10.7,10.5,10.3,10.1,9.8,9.6,9.4,9.2,9,8.7,8.5,8.3,8,7.8,7.5,7.3,7,6.8,6.5,6.2,6,5.7,5.4,5.1,4.8,4.5,4.2,3.9,3.6,3.3,3,2.7,2.3,2,1.6,1.3,0.9,0.5,0.1,,,,,,,,,,",
  "15.7,15.4,15,14.7,14.4,14,13.7,13.3,13,12.6,12.2,11.8,11.6,11.4,11.2,11,10.7,10.5,10.3,10.1,9.9,9.7,9.4,9.2,9,8.7,8.5,8.2,8,7.7,7.5,7.2,7,6.7,6.4,6.2,5.9,5.6,5.3,5,4.7,4.4,4.1,3.8,3.4,3.1,2.8,2.4,2.1,1.7,1.3,1,0.6,0.2,,,,,,,,,",
  "16.2,15.9,15.5,15.2,14.9,14.5,14.2,13.8,13.5,13,12.7,12.3,12.1,11.9,11.6,11.4,11.2,11,10.8,10.6,10.4,10.1,9.9,9.7,9.4,9.2,9,8.7,8.5,8.2,8,7.7,7.4,7.2,6.9,6.6,6.3,6.1,5.8,5.5,5.2,4.9,4.5,4.2,3.9,3.6,3.2,2.9,2.5,2.2,1.8,1.4,1,0.6,0.2,,,,,,,,",
  "16.7,16.4,16,15.7,15.3,15,14.7,14.3,13.9,13.5,13.1,12.7,12.5,12.3,12.1,11.9,11.7,11.5,11.3,11.1,10.8,10.6,10.4,10.1,9.9,9.7,9.4,9.2,8.9,8.7,8.4,8.2,7.9,7.6,7.4,7.1,6.8,6.5,6.2,5.9,5.6,5.3,5,4.7,4.3,4,3.7,3.3,3,2.6,2.2,1.8,1.4,1,0.6,0.2,,,,,,,",
  "17.2,16.9,16.5,16.2,15.8,15.5,15.2,14.8,14.4,14,13.6,13.2,13,12.8,12.6,12.4,12.2,12,11.8,11.5,11.3,11.1,10.9,10.6,10.4,10.1,9.9,9.7,9.4,9.2,8.9,8.6,8.4,8.1,7.8,7.5,7.3,7,6.7,6.4,6.1,5.8,5.4,5.1,4.8,4.5,4.1,3.8,3.4,3,2.7,2.3,1.9,1.5,1.1,0.6,0.2,,,,,,",
  "17.7,17.4,17,16.7,16.3,16,15.7,15.3,14.9,14.5,14.1,13.7,13.5,13.3,13.1,12.9,12.7,12.5,12.2,12,11.8,11.6,11.3,11.1,10.9,10.6,10.4,10.1,9.9,9.6,9.4,9.1,8.8,8.6,8.3,8,7.7,7.4,7.1,6.8,6.5,6.2,5.9,5.6,5.2,4.9,4.6,4.2,3.9,3.5,3.1,2.7,2.3,1.9,1.5,1.1,0.6,0.2,,,,,",
  "18.2,17.8,17.5,17.2,16.8,16.5,16.2,15.7,15.4,15,14.6,14.2,14,13.8,13.6,13.4,13.1,12.9,12.7,12.5,12.3,12,11.8,11.6,11.3,11.1,10.8,10.6,10.3,10.1,9.8,9.6,9.3,9,8.7,8.5,8.2,7.9,7.6,7.3,7,6.7,6.4,6,5.7,5.4,5,4.7,4.3,3.9,3.6,3.2,2.8,2.4,1.9,1.5,1.1,0.6,0.2,,,,",
  "18.7,18.3,18,17.7,17.3,17,16.7,16.2,15.9,15.5,15.1,14.7,14.5,14.3,14.1,13.8,13.6,13.4,13.2,13,12.7,12.5,12.3,12,11.8,11.6,11.3,11.1,10.8,10.6,10.3,10,9.8,9.5,9.2,8.9,8.6,8.4,8.1,7.8,7.4,7.1,6.8,6.5,6.1,5.8,5.5,5.1,4.7,4.4,4,3.6,3.2,2.8,2.4,2,1.5,1.1,0.6,0.1,,,",
  "19.2,18.8,18.5,18.2,17.8,17.5,17.2,16.7,16.3,16,15.6,15.2,15,14.7,14.5,14.3,14.1,13.9,13.7,13.4,13.2,13,12.7,12.5,12.3,12,11.8,11.5,11.3,11,10.8,10.5,10.2,10,9.7,9.4,9.1,8.8,8.5,8.2,7.9,7.6,7.3,6.9,6.6,6.3,5.9,5.6,5.2,4.8,4.4,4,3.6,3.2,2.8,2.4,1.9,1.5,1,0.5,0,,",
  "19.7,19.3,19,18.7,18.3,18,17.6,17.2,16.8,16.4,16,15.6,15.4,15.2,15,14.8,14.6,14.4,14.1,13.9,13.7,13.5,13.2,13,12.7,12.5,12.3,12,11.7,11.5,11.2,11,10.7,10.4,10.1,9.9,9.6,9.3,9,8.7,8.4,8,7.7,7.4,7.1,6.7,6.4,6,5.6,5.3,4.9,4.5,4.1,3.7,3.3,2.8,2.4,1.9,1.4,1,0.5,,",
  "20.2,19.8,19.5,19.2,18.8,18.4,18.1,17.7,17.3,16.9,16.5,16.1,15.9,15.7,15.5,15.3,15.1,14.8,14.6,14.4,14.2,13.9,13.7,13.5,13.2,13,12.7,12.5,12.2,12,11.7,11.4,11.2,10.9,10.6,10.3,10,9.7,9.4,9.1,8.8,8.5,8.2,7.8,7.5,7.2,6.8,6.4,6.1,5.7,5.3,4.9,4.5,4.1,3.7,3.3,2.8,2.3,1.9,1.4,0.9,0.4,",
  "20.7,20.3,20,19.6,19.3,18.9,18.6,18.2,17.8,17.4,17,16.6,16.4,16.2,16,15.8,15.5,15.3,15.1,14.9,14.6,14.4,14.2,13.9,13.7,13.4,13.2,12.9,12.7,12.4,12.2,11.9,11.6,11.3,11.1,10.8,10.5,10.2,9.9,9.6,9.3,8.9,8.6,8.3,8,7.6,7.3,6.9,6.5,6.2,5.8,5.4,5,4.6,4.1,3.7,3.2,2.8,2.3,1.8,1.3,0.8,0.2",
  "21.2,20.8,20.5,20.1,19.8,19.4,19.1,18.7,18.3,17.9,17.5,17.1,16.9,16.7,16.5,16.2,16,15.8,15.6,15.3,15.1,14.9,14.6,14.4,14.2,13.9,13.7,13.4,13.2,12.9,12.6,12.4,12.1,11.8,11.5,11.2,10.9,10.6,10.3,10,9.7,9.4,9.1,8.7,8.4,8.1,7.7,7.3,7,6.6,6.2,5.8,5.4,5,4.6,4.1,3.7,3.2,2.7,2.2,1.7,1.2,0.7",
  "21.7,21.3,21,20.6,20.3,19.9,19.5,19.2,18.8,18.4,18,17.6,17.4,17.2,16.9,16.7,16.5,16.3,16.1,15.8,15.6,15.4,15.1,14.9,14.6,14.4,14.1,13.9,13.6,13.4,13.1,12.8,12.5,12.3,12,11.7,11.4,11.1,10.8,10.5,10.2,9.9,9.5,9.2,8.9,8.5,8.2,7.8,7.4,7,6.7,6.3,5.8,5.4,5,4.6,4.1,3.6,3.2,2.7,2.2,1.6,1.1",
  "22.2,21.8,21.5,21.1,20.8,20.4,20,19.7,19.3,18.9,18.5,18.1,17.8,17.6,17.4,17.2,17,16.8,16.5,16.3,16.1,15.8,15.6,15.4,15.1,14.9,14.6,14.4,14.1,13.8,13.6,13.3,13,12.7,12.4,12.2,11.9,11.6,11.3,10.9,10.6,10.3,10,9.6,9.3,9,8.6,8.2,7.9,7.5,7.1,6.7,6.3,5.9,5.4,5,4.5,4.1,3.6,3.1,2.6,2.1,1.5",
  "22.7,22.3,22,21.6,21.3,20.9,20.5,20.1,19.8,19.4,19,18.5,18.3,18.1,17.9,17.7,17.5,17.2,17,16.8,16.5,16.3,16.1,15.8,15.6,15.3,15.1,14.8,14.6,14.3,14,13.8,13.5,13.2,12.9,12.6,12.3,12,11.7,11.4,11.1,10.8,10.4,10.1,9.8,9.4,9,8.7,8.3,7.9,7.5,7.1,6.7,6.3,5.9,5.4,5,4.5,4,3.5,3,2.5,1.9",
  "23.2,22.8,22.5,22.1,21.8,21.4,21,20.6,20.2,19.8,19.4,19,18.8,18.6,18.4,18.2,17.9,17.7,17.5,17.3,17,16.8,16.5,16.3,16.1,15.8,15.5,15.3,15,14.8,14.5,14.2,13.9,13.7,13.4,13.1,12.8,12.5,12.2,11.9,11.5,11.2,10.9,10.6,10.2,9.9,9.5,9.1,8.8,8.4,8,7.6,7.2,6.7,6.3,5.9,5.4,4.9,4.5,4,3.4,2.9,2.4",
  "23.7,23.3,23,22.6,22.3,21.9,21.5,21.1,20.7,20.3,19.9,19.5,19.3,19.1,18.9,18.6,18.4,18.2,18,17.7,17.5,17.3,17,16.8,16.5,16.3,16,15.8,15.5,15.2,15,14.7,14.4,14.1,13.8,13.5,13.2,12.9,12.6,12.3,12,11.7,11.3,11,10.7,10.3,9.9,9.6,9.2,8.8,8.4,8,7.6,7.2,6.7,6.3,5.8,5.4,4.9,4.4,3.9,3.3,2.8",
  "24.2,23.8,23.5,23.1,22.7,22.4,22,21.6,21.2,20.8,20.4,20,19.8,19.6,19.3,19.1,18.9,18.7,18.4,18.2,18,17.7,17.5,17.2,17,16.7,16.5,16.2,16,15.7,15.4,15.1,14.9,14.6,14.3,14,13.7,13.4,13.1,12.8,12.5,12.1,11.8,11.5,11.1,10.8,10.4,10,9.6,9.3,8.9,8.5,8,7.6,7.2,6.7,6.3,5.8,5.3,4.8,4.3,3.8,3.2",
  "24.7,24.3,24,23.6,23.2,22.9,22.5,22.1,21.7,21.3,20.9,20.5,20.3,20,19.8,19.6,19.4,19.1,18.9,18.7,18.4,18.2,18,17.7,17.5,17.2,17,16.7,16.4,16.2,15.9,15.6,15.3,15,14.8,14.5,14.2,13.9,13.5,13.2,12.7,12.6,12.2,11.9,11.6,11.2,10.8,10.5,10.1,9.7,9.3,8.9,8.5,8.1,7.6,7.2,6.7,6.2,5.7,5.2,4.7,4.2,3.6",
  "25.2,24.8,24.5,24.1,23.7,23.4,23,22.6,22.2,21.8,21.4,21,20.7,20.5,20.3,20.1,19.9,19.6,19.4,19.2,18.9,18.7,18.4,18.2,17.9,17.7,17.4,17.2,16.9,16.6,16.4,16.1,15.8,15.5,15.2,14.9,14.6,14.3,14,13.7,13.4,13,12.7,12.4,12,11.7,11.3,10.9,10.5,10.1,9.7,9.3,8.9,8.5,8.1,7.6,7.1,6.7,6.2,5.7,5.1,4.6,4",
  "25.7,25.3,25,24.6,24.2,23.9,23.5,23.1,22.7,22.3,21.9,21.4,21.2,21,20.8,20.6,20.3,20.1,19.9,19.6,19.4,19.2,18.9,18.7,18.4,18.2,17.9,17.6,17.4,17.1,16.8,16.5,16.3,16,15.7,15.4,15.1,14.8,14.5,14.1,13.8,13.5,13.2,12.8,12.5,12.1,11.7,11.4,11,10.6,10.2,9.8,9.4,8.9,8.5,8,7.6,7.1,6.6,6.1,5.6,5,4.5",
  "26.2,25.8,25.5,25.1,24.7,24.3,24,23.6,23.2,22.8,22.3,21.9,21.7,21.5,21.3,21,20.8,20.6,20.3,20.1,19.9,19.6,19.4,19.1,18.9,18.6,18.4,18.1,17.8,17.6,17.3,17,16.7,16.4,16.1,15.8,15.5,15.2,14.9,14.6,14.3,13.9,13.6,13.3,12.9,12.5,12.2,11.8,11.4,11,10.6,10.2,9.8,9.4,8.9,8.5,8,7.5,7,6.5,6,5.5,4.9",
  "26.7,26.3,25.9,25.6,25.2,24.8,24.5,24.1,23.7,23.3,22.8,22.4,22.2,22,21.7,21.5,21.3,21.1,20.8,20.6,20.3,20.1,19.9,19.6,19.4,19.1,18.8,18.6,18.3,18,17.8,17.5,17.2,16.9,16.6,16.3,16,15.7,15.4,15.1,14.7,14.4,14.1,13.7,13.4,13,12.6,12.3,11.9,11.5,11.1,10.7,10.2,9.8,9.4,8.9,8.4,8,7.5,6.9,6.4,5.9,5.3",
  "27.2,26.8,26.4,26.1,25.7,25.3,24.9,24.5,24.1,23.7,23.3,22.9,22.7,22.4,22.2,22,21.8,21.5,21.3,21.1,20.8,20.6,20.3,20.1,19.8,19.6,19.3,19,18.8,18.5,18.2,17.9,17.7,17.4,17.1,16.8,16.5,16.1,15.8,15.5,15.2,14.8,14.5,14.2,13.8,13.4,13.1,12.7,12.3,11.9,11.5,11.1,10.7,10.2,9.8,9.3,8.9,8.4,7.9,7.4,6.8,6.3,5.7",
  "27.7,27.3,26.9,26.6,26.2,25.8,25.4,25,24.6,24.2,23.8,23.4,23.1,22.9,22.7,22.5,22.2,22,21.8,21.5,21.3,21.1,20.8,20.6,20.3,20,19.8,19.5,19.2,19,18.7,18.4,18.1,17.8,17.5,17.2,16.9,16.6,16.3,16,15.6,15.3,15,14.6,14.3,13.9,13.5,13.1,12.8,12.4,12,11.5,11.1,10.7,10.2,9.8,9.3,8.8,8.3,7.8,7.3,6.7,6.2",
  "28.2,27.8,27.4,27.1,26.7,26.3,25.9,25.5,25.1,24.7,24.3,23.9,23.6,23.4,23.2,23,22.7,22.5,22.3,22,21.8,21.5,21.3,21,20.8,20.5,20.2,20,19.7,19.4,19.2,18.9,18.6,18.3,18,17.7,17.4,17.1,16.7,16.4,16.1,15.8,15.4,15.1,14.7,14.3,14,13.6,13.2,12.8,12.4,12,11.6,11.1,10.7,10.2,9.7,9.2,8.7,8.2,7.7,7.1,6.6",
  "28.7,28.3,27.9,27.6,27.2,26.8,26.4,26,25.6,25.2,24.8,24.3,24.1,23.9,23.7,23.4,23.2,23,22.7,22.5,22.2,22,21.7,21.5,21.2,21,20.7,20.4,20.2,19.9,19.6,19.3,19,18.7,18.4,18.1,17.8,17.5,17.2,16.9,16.5,16.2,15.9,15.5,15.2,14.8,14.4,14,13.6,13.2,12.8,12.4,12,11.6,11.1,10.6,10.2,9.7,9.2,8.7,8.1,7.6,7",
  "29.1,28.8,28.4,28.1,27.7,27.3,26.9,26.5,26.1,25.7,25.3,24.8,24.6,24.4,24.1,23.9,23.7,23.4,23.2,23,22.7,22.5,22.2,22,21.7,21.4,21.1,20.9,20.6,20.4,20.1,19.8,19.5,19.2,18.9,18.6,18.3,18,17.7,17.3,17,16.7,16.3,16,15.6,15.2,14.9,14.5,14.1,13.7,13.3,12.9,12.4,12,11.5,11.1,10.6,10.1,9.6,9.1,8.5,8,7.4",
  "29.6,29.3,28.9,28.6,28.2,27.8,27.4,27,26.6,26.2,25.7,25.3,25.1,24.9,24.6,24.4,24.2,23.9,23.7,23.4,23.2,22.9,22.7,22.4,22.2,21.9,21.7,21.4,21.1,20.8,20.5,20.3,20,19.7,19.4,19.1,18.8,18.4,18.1,17.8,17.5,17.1,16.8,16.4,16.1,15.7,15.3,14.9,14.5,14.1,13.7,13.3,12.9,12.4,12,11.5,11,10.5,10,9.5,9,8.4,7.8",
  "30.1,29.8,29.4,29,28.7,28.3,27.9,27.5,27.1,26.7,26.2,25.8,25.6,25.3,25.1,24.9,24.6,24.4,24.2,23.9,23.7,23.4,23.2,22.9,22.7,22.4,22.1,21.8,21.6,21.3,21,20.7,20.4,20.1,19.8,19.5,19.2,18.9,18.6,18.2,17.9,17.6,17.2,16.9,16.5,16.1,15.8,15.4,15,14.6,14.2,13.7,13.3,12.9,12.4,11.9,11.5,11,10.5,9.9,9.4,8.8,8.3",
  "30.6,30.3,29.9,29.5,29.2,28.8,28.4,28,27.6,27.1,26.7,26.3,26,25.8,25.6,25.4,25.1,24.9,24.6,24.4,24.1,23.9,23.6,23.4,23.1,22.9,22.6,22.3,22,21.8,21.5,21.2,20.9,20.6,20.3,20,19.7,19.4,19,18.7,18.4,18,17.7,17.3,17,16.6,16.2,15.8,15.4,15,14.6,14.2,13.7,13.3,12.8,12.4,11.9,11.4,10.9,10.4,9.8,9.3,8.7",
  "31.1,30.8,30.4,30,29.7,29.3,28.9,28.5,28,27.6,27.2,26.7,26.5,26.3,26.1,25.8,25.6,25.4,25.1,24.9,24.6,24.4,24.1,23.9,23.6,23.3,23.1,22.8,22.5,22.2,21.9,21.7,21.4,21.1,20.8,20.4,20.1,19.8,19.5,19.2,18.8,18.5,18.1,17.8,17.4,17,16.6,16.3,15.9,15.5,15,14.6,14.2,13.7,13.3,12.8,12.3,11.8,11.3,10.8,10.2,9.7,9.1",
  "31.6,31.3,30.9,30.5,30.1,29.8,29.4,28.9,28.5,28.1,27.7,27.2,27,26.8,26.5,26.3,26.1,25.8,25.6,25.3,25.1,24.8,24.6,24.3,24.1,23.8,23.5,23.3,23,22.7,22.4,22.1,21.8,21.5,21.3,20.9,20.6,20.3,19.9,19.6,19.3,18.9,18.6,18.2,17.8,17.5,17.1,16.7,16.3,15.9,15.5,15.1,14.6,14.2,13.7,13.2,12.8,12.3,11.7,11.2,10.7,10.1,9.5",
  "32.1,31.8,31.4,31,30.6,30.2,29.8,29.4,29,28.6,28.2,27.7,27.5,27.3,27,26.8,26.6,26.3,26.1,25.8,25.6,25.3,25.1,24.8,24.5,24.3,24,23.7,23.4,23.2,22.9,22.6,22.3,22,21.7,21.4,21,20.7,20.4,20.1,19.7,19.4,19,18.7,18.3,17.9,17.5,17.2,16.8,16.3,15.9,15.5,15.1,14.6,14.1,13.7,13.2,12.7,12.2,11.6,11.1,10.5,9.9",
  "32.6,32.3,31.9,31.5,31.1,30.7,30.3,29.9,29.5,29.1,28.6,28.2,28,27.7,27.5,27.3,27,26.8,26.5,26.3,26,25.8,25.5,25.3,25,24.7,24.5,24.2,23.9,23.6,23.3,23,22.7,22.4,22.1,21.8,21.5,21.2,20.9,20.5,20.2,19.8,19.5,19.1,18.7,18.4,18,17.6,17.2,16.8,16.4,15.9,15.5,15,14.6,14.1,13.6,13.1,12.6,12.1,11.5,10.9,10.4",
  "33.1,32.8,32.4,32,31.6,31.2,30.8,30.4,30,29.6,29.1,28.7,28.4,28.2,28,27.7,27.5,27.3,27,26.8,26.5,26.3,26,25.7,25.5,25.2,24.9,24.7,24.4,24.1,23.8,23.5,23.2,22.9,22.6,22.3,22,21.6,21.3,21,20.6,20.3,19.9,19.6,19.2,18.8,18.4,18,17.6,17.2,16.8,16.4,15.9,15.5,15,14.5,14,13.5,13,12.5,11.9,11.4,10.8",
  "33.6,33.3,32.9,32.5,32.1,31.7,31.3,30.9,30.5,30.1,29.6,29.2,28.9,28.7,28.5,28.2,28,27.7,27.5,27.2,27,26.7,26.5,26.2,25.9,25.7,25.4,25.1,24.8,24.6,24.3,24,23.7,23.4,23.1,22.7,22.4,22.1,21.8,21.4,21.1,20.7,20.4,20,19.6,19.3,18.9,18.5,18.1,17.7,17.2,16.8,16.4,15.9,15.4,15,14.5,14,13.5,12.9,12.4,11.8,11.2",
  "34.1,33.8,33.4,33,32.6,32.2,31.8,31.4,31,30.6,30.1,29.6,29.4,29.2,28.9,28.7,28.5,28.2,28,27.7,27.5,27.2,26.9,26.7,26.4,26.1,25.9,25.6,25.3,25,24.7,24.4,24.1,23.8,23.5,23.2,22.9,22.6,22.2,21.9,21.5,21.2,20.8,20.5,20.1,19.7,19.3,18.9,18.5,18.1,17.7,17.3,16.8,16.4,15.9,15.4,14.9,14.4,13.9,13.3,12.8,12.2,11.6",
  "34.6,34.3,33.9,33.5,33.1,32.7,32.3,31.9,31.5,31,30.6,30.1,29.9,29.7,29.4,29.2,28.9,28.7,28.4,28.2,27.9,27.7,27.4,27.2,26.9,26.6,26.3,26.1,25.8,25.5,25.2,24.9,24.6,24.3,24,23.7,23.3,23,22.7,22.3,22,21.6,21.3,20.9,20.5,20.2,19.8,19.4,19,18.6,18.1,17.7,17.2,16.8,16.3,15.8,15.3,14.8,14.3,13.8,13.2,12.6,1298,96,94,92,90,88,86,84,82,80,78,76,75,74,73,72,71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25"
}


local init_data = function(data)
    for i, v in ipairs(data) do
        local one_row = split(v, ',')
        -- ngx.say(one_row)
        -- ngx.say(v)
        local row = {}
        for _, vv in ipairs(one_row) do
            local n = tonumber(vv)
            if not n then
                n = 0
            end
            row[#row + 1] = n
        end
        if i == 1 then
            _M['humi'] = row
        else
            _M['data'][#_M['data'] + 1] = row
        end
    end
end

local get_temp_index = function(ptemp)
    local temp = ptemp
    if temp < 12 then
        temp = 12
    elseif temp > 35 then
        temp = 35
    end

    local diff = temp - 12
    local index = math.floor(diff * 2 + 0.5) + 1
    return index, temp
end

local get_humi_index = function(phumi)
    local humi_list = _M.humi
    if not humi_list then
        init_data(data_from_excel)
        humi_list = _M.humi
    end

    local humi = phumi
    if phumi > humi_list[1] then
        humi = humi_list[1]
    elseif phumi < humi_list[#humi_list] then
        humi = humi_list[#humi_list]
    end

    local end_index = 0
    for i, v in ipairs(humi_list) do
        if humi >= v then
            end_index = i
            break
        end
    end

    return end_index, humi
end

_M.get_ld = function(ptemp, phumi)
    local temp_index = get_temp_index(ptemp)
    local humi_index, humi = get_humi_index(phumi)
    local humi_row = _M.humi

    if not(temp_index >= 1 and humi_index >= 1) then
        return nil, 'temp_index or humi_index = 0'
    end

    local data = _M.data[temp_index]
    if not data then
        return nil, 'data is nil'
    end

    if humi_row[humi_index] == humi then
        return data[humi_index] or 0
    end

    local begin_index = humi_index - 1
    local ld_bv = data[begin_index] or 0
    local ld_sv = data[humi_index] or 0
    local humi_bv = humi_row[begin_index]
    local humi_sv = humi_row[humi_index]

    local diff = (humi_bv - humi) / (humi_bv - humi_sv) * (ld_bv - ld_sv)
    return ld_bv - diff
end

-- ngx.say(_M.get_ld(12, 98))
-- ngx.say(_M.get_ld(12, 97))
-- ngx.say(_M.get_ld(12, 96))
-- ngx.say(_M.get_ld(12.5, 80))
-- ngx.say(_M.get_ld(34, 26))
-- ngx.say(_M.get_ld(34, 24))
--
-- local ins = require 'lib.inspect'
-- for _, v in ipairs(_M.data) do
--     ngx.say(ins(v))
-- end

-- local str = '0.1,,,,,,,,0,,,,,,,,,,,'
-- ngx.say(split(str, '(,)'))

-- ngx.say(get_temp_index(12))
-- ngx.say(get_temp_index(12.1))
-- ngx.say(get_temp_index(12.5))
-- ngx.say(get_temp_index(20))
-- ngx.say(get_temp_index(20.1))
-- ngx.say(get_temp_index(20.6))
-- ngx.say(get_temp_index(35))

return _M
