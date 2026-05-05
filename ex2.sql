/* 
 * PHÂN TÍCH LỖI (Execution Order & Logic):
 * 1. Lỗi xảy ra vì 'room_name' không nằm trong GROUP BY và cũng không dùng hàm gộp (MIN, MAX...).
 * 2. Khi gom nhóm theo 'hotel_id', một khách sạn có nhiều phòng. Database không biết phải lấy 
 *    'room_name' nào để hiển thị tương ứng với giá thấp nhất, gây ra sự mập mờ về dữ liệu.
 * 3. Quy tắc: Mọi cột trong SELECT phải nằm trong GROUP BY hoặc nằm trong hàm gộp.
 */

-- [Thực thi]: Lấy ID khách sạn và giá rẻ nhất (Chấp nhận bỏ room_name để đúng logic gom nhóm)
SELECT 
    hotel_id, 
    MIN(price_per_night) AS min_price
FROM 
    Rooms
GROUP BY 
    hotel_id;

/*
 * GIẢI PHÁP: Để lấy được cả tên phòng rẻ nhất, đại ka cần dùng Subquery hoặc Window Function,
 * nhưng với yêu cầu lấy "Giá chỉ từ", câu lệnh trên là tối ưu và chính xác nhất.
 */