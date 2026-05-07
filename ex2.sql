/* * TỔNG HỢP LỜI GIẢI BÀI TẬP THỰC HÀNH SQL - RIKKEI EDUCATION
 * Người thực hiện: Nguyễn Trọng Khang
 * MSSV: N25DTCN028
 * ---------------------------------------------------------
 */

-- =========================================================
-- BÀI 1: FIX BUG MODULE "BIỂU ĐỒ DOANH THU THEO THÀNH PHỐ"
-- =========================================================
/* * PHÂN TÍCH LỖI: Dùng hàm gộp SUM(total_price) trong mệnh đề WHERE.
 * KIẾN THỨC: Thứ tự thực thi SQL là FROM -> WHERE -> GROUP BY -> HAVING. 
 * WHERE chạy TRƯỚC khi gom nhóm, nên tại bước này máy chưa biết "Tổng" là bao nhiêu.
 * GIẢI PHÁP: Chuyển điều kiện lọc giá trị tổng sang mệnh đề HAVING.
 */

SELECT 
    city, 
    SUM(total_price) AS revenue
FROM 
    Bookings
-- Bước 1: Lọc bỏ các đơn chưa hoàn tất ngay từ đầu để tối ưu hiệu năng
WHERE 
    status = 'COMPLETED'
-- Bước 2: Gom nhóm theo từng thành phố
GROUP BY 
    city
-- Bước 3: Lọc kết quả dựa trên tổng doanh thu đã tính toán
HAVING 
    SUM(total_price) > 0;


-- =========================================================
-- BÀI 2: TÍNH NĂNG "GIÁ CHỈ TỪ..." TRÊN DANH SÁCH KHÁCH SẠN
-- =========================================================
/* * PHÂN TÍCH LỖI: Vi phạm quy tắc ONLY_FULL_GROUP_BY.
 * KIẾN THỨC: Một khách sạn có nhiều tên phòng. Khi gom nhóm theo khách sạn, 
 * SQL không biết lấy tên phòng nào để đi kèm với giá thấp nhất, gây mập mờ dữ liệu.
 * GIẢI PHÁP: Loại bỏ cột room_name khỏi danh sách SELECT.
 */

SELECT 
    hotel_id, 
    MIN(price_per_night) AS min_price
FROM 
    Rooms
GROUP BY 
    hotel_id;


-- =========================================================
-- BÀI 3: SỬA LỖI MODULE "KHUYẾN MÃI" (ĐỘ ƯU TIÊN TOÁN TỬ)
-- =========================================================
/* * PHÂN TÍCH LỖI: Toán tử AND được ưu tiên xử lý trước toán tử OR.
 * KIẾN THỨC: Câu lệnh cũ bị hiểu sai thành: (Quận 1) HOẶC (Quận 3 VÀ rating > 4.0).
 * GIẢI PHÁP: Dùng dấu ngoặc đơn () để ép SQL xử lý nhóm các Quận trước.
 */

SELECT 
    restaurant_name, 
    address, 
    rating
FROM 
    Restaurants
WHERE 
    (district = 'Quận 1' OR district = 'Quận 3') 
    AND rating > 4.0;


-- =========================================================
-- BÀI 4: VÁ LỖI "TOP QUÁN ĂN MỚI NỔI" (THIẾU SẮP XẾP)
-- =========================================================
/* * PHÂN TÍCH LỖI: Sử dụng LIMIT mà không có ORDER BY.
 * KIẾN THỨC: Nếu không sắp xếp, LIMIT sẽ lấy 5 dòng bất kỳ mà nó thấy trước.
 * GIẢI PHÁP: Thêm ORDER BY created_at DESC để lấy đúng 5 quán mới nhất.
 */

SELECT 
    restaurant_name, 
    created_at
FROM 
    Restaurants
ORDER BY 
    created_at DESC
LIMIT 5;


-- =========================================================
-- BÀI 5: TOOL "TRUY QUÉT TÀI KHOẢN ĐẦU CƠ" (ANTI-FRAUD)
-- =========================================================
/* * KỸ THUẬT: Conditional Aggregation (Gộp có điều kiện).
 * KIẾN THỨC: Dùng SUM kết hợp CASE WHEN để đếm riêng số đơn bị hủy trong nhóm.
 * Việc này giúp xử lý logic phức tạp ngay trong một lần quét dữ liệu.
 */

SELECT 
    user_id,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_count
FROM 
    Bookings
GROUP BY 
    user_id
HAVING 
    COUNT(*) >= 10 
    AND SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) > 5;


-- =========================================================
-- BÀI 6: BÁO CÁO "KHÁCH SẠN ĐẠT CHUẨN" (TỐI ƯU PERFORMANCE)
-- =========================================================
/* * CHIẾN THUẬT: Lọc sớm (Filter Early) bằng WHERE.
 * KIẾN THỨC: Loại bỏ đơn rác trước khi GROUP BY giúp tiết kiệm cực lớn tài nguyên 
 * RAM/CPU vì Database không phải tính toán trên dữ liệu thừa.
 */

SELECT 
    hotel_id,
    COUNT(*) AS completed_count,
    AVG(total_price) AS avg_revenue
FROM 
    Bookings
WHERE 
    status = 'COMPLETED'
GROUP BY 
    hotel_id
HAVING 
    COUNT(*) >= 50 
    AND AVG(total_price) > 3000000;


-- =========================================================
-- BÀI 7: CẢNH BÁO "PHÒNG CHẾT" (ANTI-NULL IN NOT IN)
-- =========================================================
/* * KỸ THUẬT: LEFT JOIN + IS NULL.
 * KIẾN THỨC: Tránh dùng NOT IN vì nó sẽ trả về rỗng nếu danh sách có chứa NULL.
 * LEFT JOIN giúp tìm ra những phòng mồ côi (chưa từng có giao dịch) một cách an toàn.
 */

SELECT 
    R.room_id, 
    R.room_name
FROM 
    Rooms R
LEFT JOIN 
    Bookings B ON R.room_id = B.room_id
WHERE 
    B.room_id IS NULL;

-- ---------------------------------------------------------
-- EM XIN HẾT!