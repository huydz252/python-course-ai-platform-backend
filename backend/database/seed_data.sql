-- ========================================================
-- CHÈN DỮ LIỆU MẪU (SEED DATA) CHO PYTHON AI LEARNING 
-- (ĐÃ CHUẨN HÓA CHO POSTGRESQL / SUPABASE)
-- ========================================================

DELETE FROM admin_audit_logs;
DELETE FROM notifications;
DELETE FROM contact_messages;
DELETE FROM learning_activities;
DELETE FROM lesson_progress;
DELETE FROM enrollments;
DELETE FROM quiz_attempt_answers;
DELETE FROM quiz_attempts;
DELETE FROM quiz_options;
DELETE FROM quiz_questions;
DELETE FROM quizzes;
DELETE FROM ai_retrieval_logs;
DELETE FROM ai_chat_messages;
DELETE FROM ai_chat_sessions;
DELETE FROM transcript_chunks;
DELETE FROM lesson_summaries;
DELETE FROM lesson_transcripts;
DELETE FROM lesson_videos;
DELETE FROM lessons;
DELETE FROM course_sections;
DELETE FROM courses;
DELETE FROM user_settings;
DELETE FROM password_reset_tokens;
DELETE FROM users;

-- --------------------------------------------------------
-- NHÓM 1: NGƯỜI DÙNG VÀ TÀI KHOẢN
-- --------------------------------------------------------

INSERT INTO users (id, username, email, password_hash, phone, full_name, avatar_url, role, status) VALUES
(1, 'admin_system', 'admin@pythonailearning.edu.vn', '$2b$12$hFRC27ygA5jLG9GID8V5QOjVz6oSieLyFlPe9aC4WwDh2Y0jjV/ea', '0905111222', 'ADMIN', 'https://api.dicebear.com/7.x/adventurer/svg?seed=admin', 'admin', 'active'),
(2, 'thinh_tran', 'thinhnguyen@student.edu.vn', '$2b$12$hFRC27ygA5jLG9GID8V5QOjVz6oSieLyFlPe9aC4WwDh2Y0jjV/ea', '0905333444', 'Trần Kim Thịnh', 'https://api.dicebear.com/7.x/adventurer/svg?seed=thinh', 'student', 'active'),
(3, 'huydz252', '252quanghuy@gmail.com', '$2b$12$hFRC27ygA5jLG9GID8V5QOjVz6oSieLyFlPe9aC4WwDh2Y0jjV/ea', '0813118974', 'Trần Quang Huy', 'https://api.dicebear.com/7.x/adventurer/svg?seed=huy', 'student', 'active'),
(4, 'tien_nguyen', 'tiennguyen@student.edu.vn', '$2b$12$hFRC27ygA5jLG9GID8V5QOjVz6oSieLyFlPe9aC4WwDh2Y0jjV/ea', '0905777888', 'Tiến Nguyễn', 'https://api.dicebear.com/7.x/adventurer/svg?seed=nguyen', 'student', 'active');

INSERT INTO user_settings (id, user_id, two_factor_enabled, save_ai_history, learning_reminder_enabled, theme) VALUES
(1, 1, TRUE, TRUE, FALSE, 'dark'),
(2, 2, FALSE, TRUE, TRUE, 'system'),
(3, 3, FALSE, TRUE, TRUE, 'light'),
(4, 4, FALSE, FALSE, TRUE, 'system');

-- --------------------------------------------------------
-- NHÓM 2: KHÓA HỌC, CHƯƠNG, BÀI HỌC VÀ VIDEO
-- --------------------------------------------------------

INSERT INTO courses (id, title, slug, description, thumbnail_url, level, price, status, created_by) VALUES
(1,'Lập trình Python Cơ Bản đến Nâng Cao', 'python-co-ban-den-nang-cao', 'Khóa học cung cấp nền tảng lập trình Python từ cơ bản đến nâng cao, giúp người học nắm vững cú pháp, tư duy giải quyết vấn đề và cách ứng dụng AI Assistant để hỗ trợ viết code hiệu quả hơn.', 'https://storage.googleapis.com/python-ai-assets/thumbnails/python-basic.png', 'beginner', 0.00, 'published', 1),
(2,'Khóa học lập trình website với Python Django','lap-trinh-website-voi-python-django','Khóa học hướng dẫn xây dựng website bằng Python Django từ cơ bản, bao gồm tạo project, tạo web app, xử lý template, làm việc với database, hệ thống admin, form đăng ký, đăng nhập, generic view và xử lý bình luận.','https://storage.googleapis.com/python-ai-assets/thumbnails/python-django.png','beginner',0.00,'published',1);

INSERT INTO course_sections (id, course_id, title, sort_order) VALUES
(1, 1, 'Học Công Nghệ', 1),
(2, 2, 'K-Team', 1);

INSERT INTO lessons (id, course_id, section_id, title, description, duration_seconds, sort_order, is_free, status) VALUES
(1, 1, 1, 'Giới thiệu khóa học lập trình Python hoàn toàn miễn phí trên kênh học công nghệ', 'Giới thiệu tổng quan khóa học, nội dung học và định hướng học Python từ cơ bản.', 294, 1, TRUE, 'published'),
(2, 1, 1, 'Giới thiệu về khoá học Lập trình Python - Cài đặt Python và Visual Studio Code', 'Hướng dẫn cài đặt Python, Visual Studio Code và chuẩn bị môi trường lập trình.', 1716, 2, TRUE, 'published'),
(3, 1, 1, 'Lập trình Python cơ bản - nâng cao: Xử lý một số lỗi thường gặp khi không chạy được Python', 'Hướng dẫn nhận biết và xử lý các lỗi thường gặp khi cài đặt hoặc chạy Python.', 475, 3, TRUE, 'published'),
(4, 1, 1, 'Thực hành Code một số ví dụ đơn giản trên Python', 'Thực hành các ví dụ lập trình Python đơn giản để làm quen với cú pháp.', 1353, 4, TRUE, 'published'),
(5, 1, 1, 'Hướng dẫn sử dụng Website ideone để lưu trữ code lập trình trực tuyến một cách dễ dàng nhất', 'Hướng dẫn sử dụng công cụ trực tuyến để viết, lưu trữ và chạy thử code Python.', 628, 5, TRUE, 'published'),
(6, 1, 1, 'Khai báo biến trong Python', 'Tìm hiểu cách khai báo biến, đặt tên biến và sử dụng biến trong Python.', 459, 6, TRUE, 'published'),
(7, 1, 1, 'Kiểu dữ liệu CHUỖI trong Python', 'Giới thiệu kiểu dữ liệu chuỗi và các thao tác cơ bản với chuỗi trong Python.', 1449, 7, TRUE, 'published'),
(8, 1, 1, 'Kiểu dữ liệu CHUỖI trong Python (phần 2)', 'Thực hành nâng cao các thao tác xử lý chuỗi trong Python.', 1861, 8, TRUE, 'published'),
(9, 1, 1, 'Kiểu dữ liệu SỐ, toán tử trong lập trình Python', 'Tìm hiểu kiểu dữ liệu số và các toán tử cơ bản trong Python.', 1422, 9, TRUE, 'published'),
(10, 1, 1, 'Phép toán thao tác bit (bitwise) trong Python', 'Giới thiệu các phép toán thao tác bit và cách sử dụng trong Python.', 975, 10, TRUE, 'published'),
(11, 1, 1, 'Bài tập luyện tập xử lý, tính toán cơ bản trong Python', 'Luyện tập các bài toán tính toán cơ bản bằng Python.', 819, 11, TRUE, 'published'),
(12, 1, 1, 'Hàm nhập dữ liệu, thêm thư viện (import) và chuyển đổi kiểu dữ liệu trong Python', 'Hướng dẫn nhập dữ liệu, import thư viện và chuyển đổi kiểu dữ liệu.', 0, 12, TRUE, 'published'),
(13, 1, 1, 'Một số bài tập vận dụng tính toán cơ bản bằng Python', 'Thực hành thêm các bài tập vận dụng toán tử và tính toán cơ bản.', 355, 13, TRUE, 'published'),
(14, 1, 1, 'Sử dụng cấu trúc rẽ nhánh IF trong lập trình Python', 'Tìm hiểu cấu trúc điều kiện IF và cách rẽ nhánh chương trình.', 888, 14, TRUE, 'published'),
(15, 1, 1, 'Bài tập vận dụng cấu trúc IF trong Python (Phần 1)', 'Luyện tập xử lý điều kiện bằng cấu trúc IF trong Python.', 0, 15, TRUE, 'published'),
(16, 1, 1, 'Bài tập vận dụng cấu trúc IF trong Python (Phần 2)', 'Tiếp tục luyện tập các bài toán sử dụng cấu trúc IF.', 1764, 16, TRUE, 'published'),
(17, 1, 1, 'Cấu trúc lặp FOR, WHILE và lệnh BREAK, CONTINUE trong Python', 'Giới thiệu vòng lặp for, while và cách dùng break, continue.', 2182, 17, TRUE, 'published'),
(18, 1, 1, 'Một số bài tập vận dụng cấu trúc lặp FOR trong lập trình Python', 'Luyện tập sử dụng vòng lặp FOR để giải các bài toán cơ bản.', 0, 18, TRUE, 'published'),
(19, 1, 1, 'Một số bài tập vận dụng cấu trúc lặp WHILE trong lập trình Python', 'Luyện tập sử dụng vòng lặp WHILE trong các bài toán thực hành.', 1581, 19, TRUE, 'published'),
(20, 1, 1, 'Chữa bài tiền xu - đề thi Học sinh giỏi Trung học Cơ sở - code bằng Python', 'Chữa bài toán tiền xu bằng ngôn ngữ Python.', 787, 20, TRUE, 'published'),
(21, 1, 1, 'Cấu trúc dữ liệu danh sách (list) trong Python', 'Tìm hiểu danh sách list và các thao tác xử lý list trong Python.', 2346, 21, TRUE, 'published'),
(22, 1, 1, 'Code ứng dụng mô phỏng máy rút tiền ATM bằng Python', 'Thực hành xây dựng chương trình mô phỏng máy rút tiền ATM bằng Python.', 1016, 22, TRUE, 'published'),
(23, 1, 1, 'Bài tập luyện tập sử dụng cấu trúc dữ liệu danh sách (LIST) trong Python', 'Luyện tập các bài toán sử dụng cấu trúc dữ liệu list.', 1210, 23, TRUE, 'published'),
(24, 1, 1, 'Cấu trúc dữ liệu từ điển (dict) trong Python', 'Giới thiệu dictionary và cách lưu trữ dữ liệu dạng khóa - giá trị.', 1306, 24, TRUE, 'published'),
(25, 1, 1, 'Bài tập luyện tập sử dụng cấu trúc dữ liệu từ điển (DICT) trong Python', 'Luyện tập xử lý dữ liệu bằng dictionary trong Python.', 1895, 25, TRUE, 'published'),
(26, 1, 1, 'Xây dựng hàm (thủ tục) trong Python (phần 1)', 'Giới thiệu cách xây dựng hàm và tái sử dụng code trong Python.', 1013, 26, TRUE, 'published'),
(27, 1, 1, 'Xây dựng hàm (thủ tục) trong Python (phần 2)', 'Tiếp tục tìm hiểu cách xây dựng và sử dụng hàm trong Python.', 827, 27, TRUE, 'published'),
(28, 1, 1, 'Bài tập luyện tập về xây dựng hàm (thủ tục) trong Python (phần 1)', 'Luyện tập xây dựng hàm thông qua các bài toán thực hành.', 1936, 28, TRUE, 'published'),
(29, 1, 1, 'Bài tập luyện tập về xây dựng hàm (thủ tục) trong Python (phần 2)', 'Tiếp tục luyện tập xây dựng hàm trong Python.', 1663, 29, TRUE, 'published'),
(30, 1, 1, 'Đọc ghi file (tệp) trong Python', 'Hướng dẫn đọc và ghi file trong Python.', 3025, 30, TRUE, 'published'),
(31, 1, 1, 'Giới thiệu về thư viện Pandas trong Python và cách sử dụng cơ bản', 'Giới thiệu thư viện Pandas và các thao tác sử dụng cơ bản.', 2142, 31, TRUE, 'published'),
(32, 1, 1, 'Chữa bài tập đọc ghi file trong python', 'Chữa bài tập thực hành đọc và ghi file trong Python.', 1585, 32, TRUE, 'published'),
(33, 1, 1, 'Lập trình hướng đối tượng (OOP) trong Python', 'Giới thiệu lập trình hướng đối tượng trong Python.', 2031, 33, TRUE, 'published'),
(34, 1, 1, 'Quản lý sinh viên - Chữa bài tập lập trình hướng đối tượng bằng Python', 'Chữa bài tập OOP với bài toán quản lý sinh viên.', 823, 34, TRUE, 'published'),
(35, 1, 1, 'Quản lý địa chỉ - Chữa bài tập lập trình hướng đối tượng bằng Python', 'Chữa bài tập OOP với bài toán quản lý địa chỉ.', 466, 35, TRUE, 'published'),
(36, 1, 1, 'Quản lý điểm - Chữa bài tập lập trình hướng đối tượng bằng Python', 'Chữa bài tập OOP với bài toán quản lý điểm.', 520, 36, TRUE, 'published'),
(37, 1, 1, 'Đồng hồ đơn giản - Chữa bài tập lập trình hướng đối tượng bằng Python', 'Chữa bài tập OOP xây dựng chương trình đồng hồ đơn giản.', 1056, 37, TRUE, 'published'),
(38, 1, 1, 'Quản lý điểm danh - Chữa bài tập lập trình hướng đối tượng bằng Python', 'Chữa bài tập OOP với bài toán quản lý điểm danh.', 719, 38, TRUE, 'published'),
(39, 1, 1, 'Hình chữ nhật - Chữa bài tập lập trình hướng đối tượng bằng Python', 'Chữa bài tập OOP với bài toán hình chữ nhật.', 437, 39, TRUE, 'published'),
(40, 1, 1, 'Chữa bài tập về hướng đối tượng (OOP) trong Python: Bài toán quản lý môn học (Phần 1)', 'Chữa bài tập OOP về bài toán quản lý môn học phần 1.', 1920, 40, TRUE, 'published'),
(41, 1, 1, 'Chữa bài tập về hướng đối tượng (OOP) trong Python: Bài toán quản lý môn học (Phần 2)', 'Chữa bài tập OOP về bài toán quản lý môn học phần 2.', 1759, 41, TRUE, 'published'),
(42, 1, 1, 'Chữa bài tập về hướng đối tượng (OOP) trong Python: Xây dựng lớp phương trình bậc 2 (Phần 3)', 'Chữa bài tập OOP xây dựng lớp phương trình bậc 2.', 2220, 42, TRUE, 'published'),
(43, 1, 1, 'Xây dựng chương trình quản lý sách (phần 1)', 'Thực hành xây dựng chương trình quản lý sách bằng Python phần 1.', 2000, 43, TRUE, 'published'),
(44, 1, 1, 'Xây dựng chương trình quản lý sách (phần 2)', 'Thực hành xây dựng chương trình quản lý sách bằng Python phần 2.', 1693, 44, TRUE, 'published'),
(45, 1, 1, 'Xây dựng chương trình quản lý sách (phần 3)', 'Thực hành xây dựng chương trình quản lý sách bằng Python phần 3.', 1213, 45, TRUE, 'published'),
(46, 1, 1, 'Xây dựng chương trình phát nhạc từ Internet bằng Python (phần 1)', 'Thực hành xây dựng chương trình phát nhạc từ Internet phần 1.', 1053, 46, TRUE, 'published'),
(47, 1, 1, 'Xây dựng chương trình phát nhạc từ Internet bằng Python (phần 2)', 'Thực hành xây dựng chương trình phát nhạc từ Internet phần 2.', 1499, 47, TRUE, 'published'),
(48, 1, 1, 'Xây dựng chương trình phát nhạc từ Internet bằng Python (phần 3)', 'Thực hành xây dựng chương trình phát nhạc từ Internet phần 3.', 1548, 48, TRUE, 'published'),
(49, 1, 1, 'Xây dựng chương trình phát nhạc từ Internet bằng Python (phần 4)', 'Thực hành xây dựng chương trình phát nhạc từ Internet phần 4.', 1320, 49, TRUE, 'published'),
(50, 1, 1, 'Xây dựng chương trình phát nhạc từ Internet bằng Python (phần 5)', 'Thực hành xây dựng chương trình phát nhạc từ Internet phần 5.', 2094, 50, TRUE, 'published'),
(51, 1, 1, 'Xây dựng ứng dụng sinh PASSWORD hoàn toàn ngẫu nhiên Code bằng Python', 'Thực hành xây dựng ứng dụng sinh mật khẩu ngẫu nhiên bằng Python.', 1311, 51, TRUE, 'published'),
(52, 1, 1, 'Làm Game Oẳn Tù Tì chơi với máy tính rất sinh động chỉ với 70 dòng Code bằng Python', 'Thực hành xây dựng game Oẳn Tù Tì bằng Python.', 1046, 52, TRUE, 'published'),
(53, 1, 1, 'Làm Game Hangman (đoán ô chữ) chơi với máy tính rất sinh động chỉ với 90 dòng Code bằng Python', 'Thực hành xây dựng game Hangman bằng Python.', 2121, 53, TRUE, 'published'),
(54, 1, 1, 'Làm chương trình mã hóa (code) và giải mã (encode) Caesar Cipher bằng Python', 'Thực hành xây dựng chương trình mã hóa và giải mã Caesar Cipher.', 1822, 54, TRUE, 'published'),
(55, 1, 1, 'Lập trình Game "Phiên đấu giá thầm lặng" bằng Python', 'Thực hành xây dựng game phiên đấu giá thầm lặng bằng Python.', 1042, 55, TRUE, 'published'),
(56, 1, 1, 'Lập trình Game "Đoán số" (Guess Number) bằng Python', 'Thực hành xây dựng game đoán số bằng Python.', 2520, 56, TRUE, 'published'),
(57, 1, 1, 'Lập trình Game "Cao hơn và Thấp hơn" bằng Python', 'Thực hành xây dựng game Cao hơn và Thấp hơn bằng Python.', 1902, 57, TRUE, 'published'),
(58, 1, 1, 'Giới thiệu, hướng dẫn Đăng ký - Sử dụng hệ thống luyện code "Học Công Nghệ Online Judge"', 'Hướng dẫn đăng ký và sử dụng hệ thống luyện code Học Công Nghệ Online Judge.', 1156, 58, TRUE, 'published'),
(59, 1, 1, 'Hướng dẫn cài đặt thêm thư viện trong Python sử dụng Pip Install và gỡ bỏ một thư viện', 'Hướng dẫn cài đặt và gỡ bỏ thư viện Python bằng pip.', 678, 59, TRUE, 'published'),
(60, 2, 2, 'Bài 1: Giới thiệu Django', 'Giới thiệu tổng quan về Django và vai trò của Django trong lập trình website bằng Python.', 114, 1, TRUE, 'published'),
(61, 2, 2, 'Bài 2: Tạo project Django', 'Hướng dẫn khởi tạo project Django đầu tiên và làm quen với cấu trúc thư mục cơ bản.', 256, 2, TRUE, 'published'),
(62, 2, 2, 'Bài 3: Tạo WebApp', 'Hướng dẫn tạo web app trong Django và kết nối app với project chính.', 689, 3, TRUE, 'published'),
(63, 2, 2, 'Bài 4: Template và Jinja', 'Tìm hiểu cách sử dụng template và cú pháp Jinja để hiển thị nội dung trên giao diện web.', 298, 4, TRUE, 'published'),
(64, 2, 2, 'Bài 5: Xử lý file', 'Hướng dẫn tổ chức, liên kết và xử lý các file cần thiết trong project Django.', 452, 5, TRUE, 'published'),
(65, 2, 2, 'Bài 6: Hoàn chỉnh blog', 'Thực hành hoàn thiện các phần cơ bản của website blog bằng Django.', 633, 6, TRUE, 'published'),
(66, 2, 2, 'Bài 7: Dùng Model tạo Database', 'Tìm hiểu cách sử dụng Model trong Django để tạo cấu trúc database.', 252, 7, TRUE, 'published'),
(67, 2, 2, 'Bài 8: Tương tác Database', 'Hướng dẫn tương tác với database thông qua Model và các thao tác dữ liệu cơ bản.', 352, 8, TRUE, 'published'),
(68, 2, 2, 'Bài 9: Hệ thống admin', 'Giới thiệu hệ thống quản trị admin có sẵn trong Django và cách sử dụng.', 350, 9, TRUE, 'published'),
(69, 2, 2, 'Bài 10: Liệt kê danh sách', 'Hướng dẫn lấy dữ liệu từ database và hiển thị danh sách dữ liệu lên giao diện.', 499, 10, TRUE, 'published'),
(70, 2, 2, 'Bài 11: Hiển thị bài viết', 'Thực hành hiển thị nội dung chi tiết của từng bài viết trên website Django.', 802, 11, TRUE, 'published'),
(71, 2, 2, 'Bài 12: Loại bỏ hardcode', 'Hướng dẫn thay thế dữ liệu hardcode bằng dữ liệu động từ database.', 210, 12, TRUE, 'published'),
(72, 2, 2, 'Bài 13: Xử lý lỗi 404', 'Hướng dẫn xử lý lỗi 404 khi người dùng truy cập vào nội dung không tồn tại.', 413, 13, TRUE, 'published'),
(73, 2, 2, 'Bài 14: Mô hình MVC', 'Giới thiệu mô hình MVC và cách Django tổ chức logic theo mô hình tương ứng.', 103, 14, TRUE, 'published'),
(74, 2, 2, 'Bài 15: Upload file', 'Hướng dẫn xây dựng chức năng upload file trong website Django.', 523, 15, TRUE, 'published'),
(75, 2, 2, 'Bài 16: Tạo form đăng ký', 'Thực hành tạo form đăng ký người dùng trong Django.', 1440, 16, TRUE, 'published'),
(76, 2, 2, 'Bài 17: Login - Logout', 'Hướng dẫn xây dựng chức năng đăng nhập và đăng xuất người dùng.', 619, 17, TRUE, 'published'),
(77, 2, 2, 'Bài 18: Generic view', 'Tìm hiểu Generic View trong Django để rút gọn code xử lý view.', 653, 18, TRUE, 'published'),
(78, 2, 2, 'Bài 19: Xử lý bình luận', 'Thực hành xây dựng chức năng xử lý bình luận cho bài viết trong website Django.', 1643, 19, TRUE, 'published');

INSERT INTO lesson_videos (id, lesson_id, video_url, storage_provider, file_name, file_size, duration_seconds, processing_status) VALUES
(1, 1, 'https://www.youtube.com/watch?v=ET3_kuuIGZs&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=1', 'YouTube', NULL, NULL, 294, 'completed'),
(2, 2, 'https://www.youtube.com/watch?v=FgPtO6ytP_w&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=2', 'YouTube', NULL, NULL, 1716, 'completed'),
(3, 3, 'https://www.youtube.com/watch?v=cTxQVlhCrgg&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=3', 'YouTube', NULL, NULL, 475, 'completed'),
(4, 4, 'https://www.youtube.com/watch?v=qCn3G-zJ6cQ&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=4', 'YouTube', NULL, NULL, 1353, 'completed'),
(5, 5, 'https://www.youtube.com/watch?v=b8BBaRlOqzk&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=5', 'YouTube', NULL, NULL, 628, 'completed'),
(6, 6, 'https://www.youtube.com/watch?v=dN5RH2q0wqE&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=6', 'YouTube', NULL, NULL, 459, 'completed'),
(7, 7, 'https://www.youtube.com/watch?v=UNi-yVO_Njk&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=7', 'YouTube', NULL, NULL, 1449, 'completed'),
(8, 8, 'http://youtube.com/watch?v=kHO1EU3Q6UA&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=8', 'YouTube', NULL, NULL, 1861, 'completed'),
(9, 9, 'https://www.youtube.com/watch?v=Ofh7X8fddKo&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=9', 'YouTube', NULL, NULL, 1422, 'completed'),
(10, 10, 'https://www.youtube.com/watch?v=kd7edoternk&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=10', 'YouTube', NULL, NULL, 975, 'completed'),
(11, 11, 'https://www.youtube.com/watch?v=mRC5Sl-VAu8&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=11', 'YouTube', NULL, NULL, 819, 'completed'),
(12, 12, 'https://www.youtube.com/watch?v=-_i7qCLB3hE&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=12', 'YouTube', NULL, NULL, 0, 'completed'),
(13, 13, 'https://www.youtube.com/watch?v=t8RTk4yXzbk&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=13', 'YouTube', NULL, NULL, 355, 'completed'),
(14, 14, 'https://www.youtube.com/watch?v=o3EkvqVHCQU&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=14', 'YouTube', NULL, NULL, 888, 'completed'),
(15, 15, 'https://www.youtube.com/watch?v=4embyg_k29s&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=15', 'YouTube', NULL, NULL, 0, 'completed'),
(16, 16, 'https://www.youtube.com/watch?v=b5Pntxx4sSI&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=16', 'YouTube', NULL, NULL, 1764, 'completed'),
(17, 17, 'https://www.youtube.com/watch?v=fkoBRTznbGs&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=17', 'YouTube', NULL, NULL, 2182, 'completed'),
(18, 18, 'https://www.youtube.com/watch?v=-oEN14IVxk8&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=18', 'YouTube', NULL, NULL, 0, 'completed'),
(19, 19, 'https://www.youtube.com/watch?v=yBODKOnRmU4&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=19', 'YouTube', NULL, NULL, 1581, 'completed'),
(20, 20, 'https://www.youtube.com/watch?v=U3OajWLWojE&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=20', 'YouTube', NULL, NULL, 787, 'completed'),
(21, 21, 'https://www.youtube.com/watch?v=0fvEb2ASdVM&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=21', 'YouTube', NULL, NULL, 2346, 'completed'),
(22, 22, 'https://www.youtube.com/watch?v=huUubvjFUTk&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=22', 'YouTube', NULL, NULL, 1016, 'completed'),
(23, 23, 'https://www.youtube.com/watch?v=lU4Scr_6Jhs&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=23', 'YouTube', NULL, NULL, 1210, 'completed'),
(24, 24, 'https://www.youtube.com/watch?v=xNyAXOYRSds&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=24', 'YouTube', NULL, NULL, 1306, 'completed'),
(25, 25, 'https://www.youtube.com/watch?v=iFd8c169io4&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=25', 'YouTube', NULL, NULL, 1895, 'completed'),
(26, 26, 'https://www.youtube.com/watch?v=pKpGJsjhlZI&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=26', 'YouTube', NULL, NULL, 1013, 'completed'),
(27, 27, 'https://www.youtube.com/watch?v=VD_ilCe85Ik&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=27', 'YouTube', NULL, NULL, 827, 'completed'),
(28, 28, 'https://www.youtube.com/watch?v=MKw4HXEADCg&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=28', 'YouTube', NULL, NULL, 1936, 'completed'),
(29, 29, 'https://www.youtube.com/watch?v=B8cpFG8tUns&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=29', 'YouTube', NULL, NULL, 1663, 'completed'),
(30, 30, 'https://www.youtube.com/watch?v=Uj_IdLmjk5A&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=30', 'YouTube', NULL, NULL, 3025, 'completed'),
(31, 31, 'https://www.youtube.com/watch?v=lbEuqHPbK2g&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=31', 'YouTube', NULL, NULL, 2142, 'completed'),
(32, 32, 'https://www.youtube.com/watch?v=lxTNSuLnh4U&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=32', 'YouTube', NULL, NULL, 1585, 'completed'),
(33, 33, 'https://www.youtube.com/watch?v=Nai9mGLRheU&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=33', 'YouTube', NULL, NULL, 2031, 'completed'),
(34, 34, 'https://www.youtube.com/watch?v=SZtAQsdwIgI&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=34', 'YouTube', NULL, NULL, 823, 'completed'),
(35, 35, 'https://www.youtube.com/watch?v=xpCPZyNgPZc&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=35', 'YouTube', NULL, NULL, 466, 'completed'),
(36, 36, 'https://www.youtube.com/watch?v=Z4hndJgeK7E&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=36', 'YouTube', NULL, NULL, 520, 'completed'),
(37, 37, 'https://www.youtube.com/watch?v=dneN70gNgIc&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=37', 'YouTube', NULL, NULL, 1056, 'completed'),
(38, 38, 'https://www.youtube.com/watch?v=sb5TkjT-dfQ&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=38', 'YouTube', NULL, NULL, 719, 'completed'),
(39, 39, 'https://www.youtube.com/watch?v=JM5coJDDKCU&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=39', 'YouTube', NULL, NULL, 437, 'completed'),
(40, 40, 'https://www.youtube.com/watch?v=u4kw4Kc9QO0&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=40', 'YouTube', NULL, NULL, 1920, 'completed'),
(41, 41, 'https://www.youtube.com/watch?v=Bd2hF95iRCA&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=41', 'YouTube', NULL, NULL, 1759, 'completed'),
(42, 42, 'https://www.youtube.com/watch?v=3PBhpKvwkas&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=42', 'YouTube', NULL, NULL, 2220, 'completed'),
(43, 43, 'https://www.youtube.com/watch?v=eE5jg_mrL3g&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=43', 'YouTube', NULL, NULL, 2000, 'completed'),
(44, 44, 'https://www.youtube.com/watch?v=OLJ2e4qkyXc&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=44', 'YouTube', NULL, NULL, 1693, 'completed'),
(45, 45, 'https://www.youtube.com/watch?v=5qBEHclPglM&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=45', 'YouTube', NULL, NULL, 1213, 'completed'),
(46, 46, 'https://www.youtube.com/watch?v=9Zob-3Pod2I&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=46', 'YouTube', NULL, NULL, 1053, 'completed'),
(47, 47, 'https://www.youtube.com/watch?v=W6r8X-G6vf8&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=47', 'YouTube', NULL, NULL, 1499, 'completed'),
(48, 48, 'https://www.youtube.com/watch?v=pxTIDRDmEKk&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=48', 'YouTube', NULL, NULL, 1548, 'completed'),
(49, 49, 'https://www.youtube.com/watch?v=O3SVuvzR5Dc&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=49', 'YouTube', NULL, NULL, 1320, 'completed'),
(50, 50, 'https://www.youtube.com/watch?v=UVDO27GM32o&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=50', 'YouTube', NULL, NULL, 2094, 'completed'),
(51, 51, 'https://www.youtube.com/watch?v=FqAf2rhtnu4&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=51', 'YouTube', NULL, NULL, 1311, 'completed'),
(52, 52, 'https://www.youtube.com/watch?v=hsZTwMNSZEk&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=52', 'YouTube', NULL, NULL, 1046, 'completed'),
(53, 53, 'https://www.youtube.com/watch?v=mXTga-RvVbs&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=53', 'YouTube', NULL, NULL, 2121, 'completed'),
(54, 54, 'https://www.youtube.com/watch?v=YjveRSgQJno&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=54', 'YouTube', NULL, NULL, 1822, 'completed'),
(55, 55, 'https://www.youtube.com/watch?v=kidAgHOn_YI&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=55', 'YouTube', NULL, NULL, 1042, 'completed'),
(56, 56, 'https://www.youtube.com/watch?v=nEUJJPyMGYM&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=56', 'YouTube', NULL, NULL, 2520, 'completed'),
(57, 57, 'https://www.youtube.com/watch?v=f9MBz3VGkfM&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=57', 'YouTube', NULL, NULL, 1902, 'completed'),
(58, 58, 'https://www.youtube.com/watch?v=W0IBds-7VnE&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=58', 'YouTube', NULL, NULL, 1156, 'completed'),
(59, 59, 'https://www.youtube.com/watch?v=OthFcakjl7o&list=PLzQuu4-Qxlh44nsjdQH2quvfKePtAaI3_&index=59', 'YouTube', NULL, NULL, 678, 'completed'),
(60, 60, 'https://www.youtube.com/watch?v=VF0oC9mkkno&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=1', 'YouTube', NULL, NULL, 114, 'completed'),
(61, 61, 'https://www.youtube.com/watch?v=r18_RvCOb9s&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=2', 'YouTube', NULL, NULL, 256, 'completed'),
(62, 62, 'https://www.youtube.com/watch?v=zIhLrQCFmic&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=3', 'YouTube', NULL, NULL, 689, 'completed'),
(63, 63, 'https://www.youtube.com/watch?v=p1q39gPvDAI&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=4', 'YouTube', NULL, NULL, 298, 'completed'),
(64, 64, 'https://www.youtube.com/watch?v=_D5WGp2chtk&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=5', 'YouTube', NULL, NULL, 452, 'completed'),
(65, 65, 'https://www.youtube.com/watch?v=TzWwzM0SBRk&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=6', 'YouTube', NULL, NULL, 633, 'completed'),
(66, 66, 'https://www.youtube.com/watch?v=Sc2fy1XGFMc&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=7', 'YouTube', NULL, NULL, 252, 'completed'),
(67, 67, 'https://www.youtube.com/watch?v=SlWOyt9-Tvg&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=8', 'YouTube', NULL, NULL, 352, 'completed'),
(68, 68, 'https://www.youtube.com/watch?v=ngvLEU8qOL0&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=9', 'YouTube', NULL, NULL, 350, 'completed'),
(69, 69, 'https://www.youtube.com/watch?v=iKdt5tINHRI&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=10', 'YouTube', NULL, NULL, 499, 'completed'),
(70, 70, 'https://www.youtube.com/watch?v=82D3wwoCS68&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=11', 'YouTube', NULL, NULL, 802, 'completed'),
(71, 71, 'https://www.youtube.com/watch?v=mZzsEq7vYMg&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=12', 'YouTube', NULL, NULL, 210, 'completed'),
(72, 72, 'https://www.youtube.com/watch?v=R3_1J41t5Bc&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=13', 'YouTube', NULL, NULL, 413, 'completed'),
(73, 73, 'https://www.youtube.com/watch?v=f5KbZxOoT_k&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=14', 'YouTube', NULL, NULL, 103, 'completed'),
(74, 74, 'https://www.youtube.com/watch?v=XoZJ5gDMKQA&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=15', 'YouTube', NULL, NULL, 523, 'completed'),
(75, 75, 'https://www.youtube.com/watch?v=uLSto4HtZZs&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=16', 'YouTube', NULL, NULL, 1440, 'completed'),
(76, 76, 'https://www.youtube.com/watch?v=UU9mVwZocLo&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=17', 'YouTube', NULL, NULL, 619, 'completed'),
(77, 77, 'https://www.youtube.com/watch?v=OZnssR3TqIg&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=18', 'YouTube', NULL, NULL, 653, 'completed'),
(78, 78, 'https://www.youtube.com/watch?v=rlJh36N_IYU&list=PL33lvabfss1z8GYxjyMulCnhcYGk5ah8P&index=19', 'YouTube', NULL, NULL, 1643, 'completed');

INSERT INTO lesson_summaries (lesson_id, summary_text, key_points, generated_by) VALUES
(7, 'Bài 7: Kiểu dữ liệu chuỗi STRING trong Python...', '["String", "Chuỗi", "Index", "Slicing", "Immutable", "Nối chuỗi", "Ký tự", "Chỉ số 0"]', 'AI Assistant'),
(8, 'Bài 8: Thao tác và xử lý chuỗi cơ bản...', '["strip()", "lower()", "upper()", "replace()", "split()", "Chuẩn hóa dữ liệu", "Định dạng chuỗi"]', 'AI Assistant'),
(9, 'Bài 9: Cấu trúc rẽ nhánh IF trong Python...', '["if", "elif", "else", "Điều kiện", "Toán tử so sánh", "and", "or", "not", "Indentation"]', 'AI Assistant'),
(10, 'Bài 10: Bài tập vận dụng cấu trúc IF - phần 1...', '["Bài tập if", "Số chẵn lẻ", "Số dương âm", "Phân loại", "Trường hợp biên", "Kiểm thử"]', 'AI Assistant'),
(11, 'Bài 11: Bài tập vận dụng cấu trúc IF - phần 2...', '["elif", "and", "or", "Nhiều điều kiện", "Xếp loại", "Năm nhuận", "Ngưỡng điều kiện"]', 'AI Assistant'),
(12, 'Bài 12: Cấu trúc lặp FOR, WHILE và lệnh BREAK, CONTINUE...', '["for", "while", "break", "continue", "range()", "Vòng lặp", "Điều kiện dừng", "Vòng lặp vô hạn"]', 'AI Assistant'),
(13, 'Bài 13: Một số bài tập vận dụng cấu trúc lặp WHILE...', '["while", "Điều kiện dừng", "Nhập lại dữ liệu", "Menu", "Cộng dồn", "Đếm", "Vòng lặp vô hạn"]', 'AI Assistant'),
(14, 'Bài 14: Bài tập vận dụng cấu trúc lặp FOR...', '["for", "range()", "start", "stop", "step", "Tính tổng", "Đếm", "Mẫu hình"]', 'AI Assistant'),
(15, 'Bài 15: Bài tập tổng hợp điều kiện và vòng lặp...', '["if", "for", "while", "Thuật toán cơ bản", "Số nguyên tố", "Giai thừa", "Trường hợp biên"]', 'AI Assistant'),
(16, 'Bài 16: Cấu trúc dữ liệu danh sách LIST trong Python...', '["List", "append()", "remove()", "sort()", "len()", "Index", "Duyệt danh sách", "Mutable"]', 'AI Assistant'),
(17, 'Bài 17: Bài tập luyện tập sử dụng LIST...', '["List", "Tính tổng", "Trung bình", "min()", "max()", "Lọc dữ liệu", "Sắp xếp", "IndexError"]', 'AI Assistant'),
(18, 'Bài 18: Tuple, set và các cấu trúc dữ liệu liên quan...', '["Tuple", "Set", "List", "Immutable", "Mutable", "Loại trùng", "Có thứ tự", "Không có thứ tự"]', 'AI Assistant'),
(19, 'Bài 19: Cấu trúc dữ liệu DICTIONARY trong Python...', '["Dictionary", "dict", "Key", "Value", "items()", "keys()", "values()", "KeyError", "Bản ghi"]', 'AI Assistant'),
(20, 'Bài 20: Bài tập luyện tập sử dụng DICT...', '["dict", "List of dict", "Key", "Value", "Quản lý dữ liệu", "Tìm kiếm", "Cập nhật", "KeyError"]', 'AI Assistant'),
(21, 'Bài 21: Xây dựng hàm/thủ tục trong Python - phần 1...', '["Hàm", "def", "Tham số", "return", "print()", "Tái sử dụng code", "Kiểm thử"]', 'AI Assistant'),
(22, 'Bài 22: Xây dựng hàm/thủ tục trong Python - phần 2...', '["Tham số mặc định", "Local variable", "Global variable", "global", "Tổ chức chương trình", "Tên hàm"]', 'AI Assistant'),
(23, 'Bài 23: Bài tập luyện tập về xây dựng hàm - phần 1...', '["def", "Tham số", "return", "Tính diện tích", "Kiểm tra số", "Chuẩn hóa chuỗi", "Tái sử dụng"]', 'AI Assistant'),
(24, 'Bài 24: Bài tập luyện tập về xây dựng hàm - phần 2...', '["Hàm", "Chia nhỏ bài toán", "List", "Dict", "Vòng lặp", "return", "Tên hàm", "Refactor"]', 'AI Assistant'),
(25, 'Bài 25: Bài tập luyện tập về xây dựng hàm - phần 3...', '["Hàm con", "Gọi hàm", "Kiểm tra dữ liệu", "Bảo trì code", "Debug", "Refactor"]', 'AI Assistant'),
(26, 'Bài 26: Bài tập tổng hợp nền tảng Python...', '["Tổng hợp Python", "Biến", "Điều kiện", "Vòng lặp", "List", "Dict", "Hàm", "Debug"]', 'AI Assistant'),
(27, 'Bài 27: Làm việc với file trong Python...', '["File", "open()", "read()", "readline()", "write()", "with open", "Chế độ r/w/a", "Đọc ghi dữ liệu"]', 'AI Assistant'),
(28, 'Bài 28: Lập trình hướng đối tượng OOP trong Python - phần 1...', '["OOP", "class", "object", "self", "Thuộc tính", "Đối tượng", "Lớp"]', 'AI Assistant'),
(29, 'Bài 29: Lập trình hướng đối tượng OOP trong Python - phần 2...', '["OOP", "Phương thức", "__init__", "Class", "Object", "self", "Tái sử dụng"]', 'AI Assistant'),
(30, 'Bài 30: Lập trình hướng đối tượng OOP trong Python - phần 3...', '["Thiết kế lớp", "Nhiều đối tượng", "List object", "Thuộc tính", "Phương thức", "Mô hình hóa"]', 'AI Assistant'),
(31, 'Bài 31: Kế thừa trong lập trình hướng đối tượng Python...', '["Kế thừa", "Lớp cha", "Lớp con", "super()", "Override", "Tái sử dụng code", "OOP"]', 'AI Assistant'),
(32, 'Bài 32: Bài tập OOP và quản lý dữ liệu bằng Python...', '["OOP", "Object", "List object", "Quản lý dữ liệu", "Thêm sửa xóa", "Tìm kiếm", "Phương thức"]', 'AI Assistant'),
(33, 'Bài 33: Xây dựng chương trình quản lý sách bằng Python - phần 1...', '["Quản lý sách", "Class", "List", "Thêm dữ liệu", "Hiển thị dữ liệu", "CRUD", "OOP"]', 'AI Assistant'),
(34, 'Bài 34: Xây dựng chương trình quản lý sách bằng Python - phần 2...', '["Quản lý sách", "Tìm kiếm", "Sửa", "Xóa", "CRUD", "Hàm", "Phương thức", "Lưu file"]', 'AI Assistant'),
(35, 'Bài 35: Chữa bài tiền xu - đề thi học sinh giỏi THCS...', '["Bài tiền xu", "Thuật toán", "Input", "Output", "Ràng buộc", "Tối ưu", "Kiểm thử"]', 'AI Assistant'),
(36, 'Bài 36: Giải đề thi học sinh giỏi Tin học bằng Python...', '["Đề thi Tin học", "Thuật toán", "Input", "Output", "Trường hợp biên", "Độ phức tạp", "Python"]', 'AI Assistant'),
(37, 'Bài 37: Thuật toán quay lui Backtracking...', '["Backtracking", "Quay lui", "Đệ quy", "Điều kiện dừng", "Hoàn tác", "Tổ hợp", "Hoán vị"]', 'AI Assistant'),
(38, 'Bài 38: Bài toán luyện tư duy thuật toán nâng cao...', '["Tư duy thuật toán", "Điều kiện", "Vòng lặp", "Cấu trúc dữ liệu", "Trường hợp biên", "Tối ưu", "Debug"]', 'AI Assistant'),
(39, 'Bài 39: Vẽ biểu đồ cột thể hiện thu nhập hàng tháng bằng Python...', '["Biểu đồ cột", "Trực quan hóa dữ liệu", "matplotlib", "Trục x", "Trục y", "Tiêu đề", "Nhãn trục"]', 'AI Assistant'),
(40, 'Bài 40: Giới thiệu thư viện Pandas trong Python...', '["Pandas", "Series", "DataFrame", "Excel", "CSV", "Lọc dữ liệu", "head()", "Cột dữ liệu"]', 'AI Assistant'),
(41, 'Bài 41: Làm việc với dữ liệu dạng bảng bằng Pandas...', '["Pandas", "DataFrame", "Lọc dữ liệu", "Thống kê", "Kiểu dữ liệu", "Giá trị thiếu", "Xuất file"]', 'AI Assistant'),
(42, 'Bài 42: Xây dựng chương trình phát nhạc từ Internet bằng Python...', '["Mini-project", "Phát nhạc", "Internet", "Thư viện ngoài", "Đường dẫn", "Xử lý lỗi", "Ứng dụng Python"]', 'AI Assistant'),
(43, 'Bài 43: Giới thiệu khóa học lập trình Game với Python...', '["Game Python", "Turtle", "Pygame", "Vòng lặp game", "Sự kiện", "Trạng thái", "Luật chơi"]', 'AI Assistant'),
(44, 'Bài 44: Giới thiệu thư viện Turtle - phần 1...', '["Turtle", "Screen", "forward()", "backward()", "left()", "right()", "Màu sắc", "Tọa độ"]', 'AI Assistant'),
(45, 'Bài 45: Giới thiệu thư viện Turtle - phần 2...', '["Turtle", "speed()", "goto()", "penup()", "pendown()", "Vòng lặp", "Nhiều đối tượng", "Sự kiện"]', 'AI Assistant'),
(46, 'Bài 46: Giới thiệu game cuộc đua rùa bằng Turtle...', '["Game rùa", "Turtle", "Random", "Luật chơi", "Vạch đích", "Điều kiện thắng", "Đối tượng game"]', 'AI Assistant'),
(47, 'Bài 47: Lập trình game cuộc đua rùa bằng Turtle...', '["Turtle race", "random", "Object", "Vòng lặp game", "Điều kiện dừng", "Vạch đích", "Kết quả"]', 'AI Assistant'),
(48, 'Bài 48: Giới thiệu game Pong bằng Turtle...', '["Pong", "Turtle", "Ball", "Paddle", "Va chạm", "Điểm số", "Bàn phím", "Game loop"]', 'AI Assistant'),
(49, 'Bài 49: Lập trình game Pong bằng Python - phần 1...', '["Pong", "Turtle", "Ball", "Paddle", "Keyboard", "Game loop", "screen.update()"]', 'AI Assistant'),
(50, 'Bài 50: Hoàn thiện game Pong - phần 2...', '["Pong", "Va chạm", "Paddle", "Score", "Reset ball", "Tọa độ", "Điều kiện"]', 'AI Assistant'),
(51, 'Bài 51: Giới thiệu game rắn săn mồi bằng Turtle...', '["Snake", "Turtle", "Thức ăn", "Segment", "List", "Va chạm", "Điểm số", "Luật chơi"]', 'AI Assistant'),
(52, 'Bài 52: Lập trình game rắn săn mồi - phần 1...', '["Snake", "Turtle", "Keyboard", "Direction", "Game loop", "Segment", "Trạng thái hướng"]', 'AI Assistant'),
(53, 'Bài 53: Lập trình game rắn săn mồi - phần 2...', '["Snake", "Food", "Segment", "Score", "Collision", "Random position", "Game over"]', 'AI Assistant'),
(54, 'Bài 54: Giới thiệu, cài đặt và xây dựng giao diện mặc định bằng Pygame...', '["Pygame", "pygame.init()", "display.set_mode()", "Game loop", "Event", "QUIT", "pygame.quit()"]', 'AI Assistant'),
(55, 'Bài 55: Vẽ các hình cơ bản lên giao diện Pygame...', '["Pygame", "draw.rect", "draw.circle", "draw.line", "Tọa độ", "Màu sắc", "display.update()"]', 'AI Assistant'),
(56, 'Bài 56: Làm đồng hồ thể thao bấm giờ/đếm ngược bằng Pygame...', '["Pygame", "Đồng hồ bấm giờ", "Đếm ngược", "Clock", "Font", "render text", "Event"]', 'AI Assistant'),
(57, 'Bài 57: Lập trình game “Phiên đấu giá thầm lặng” bằng Python...', '["Silent Auction", "Dictionary", "Tên người chơi", "Giá thầu", "Vòng lặp", "Max value", "Người thắng"]', 'AI Assistant'),
(58, 'Bài 58: Lập trình game “Cao hơn và Thấp hơn” bằng Python...', '["Higher Lower", "Random", "List", "Dictionary", "So sánh", "Score", "Vòng lặp game"]', 'AI Assistant'),
(59, 'Bài 59: Làm game Flappy Bird bằng Pygame - phần 1...', '["Flappy Bird", "Pygame", "Gravity", "Jump", "Pipe", "Collision", "Game loop", "Nhân Nhân vật chim"]', 'AI Assistant'),
(60, 'Bài 1: Generic View trong Django...', '["Generic View","Class-based View","ListView","DetailView","Pagination","paginate_by","queryset","as_view"]', 'AI Assistant'),
(61, 'Bài 2: Khởi tạo Project Django...', '["startproject","manage.py","settings.py","urls.py","wsgi.py","VS Code","runserver","localhost"]', 'AI Assistant'),
(62, 'Bài 3: Tạo App đầu tiên trong Django...', '["startapp","INSTALLED_APPS","HttpResponse","views.py","urls.py","include","migrate","SimpleTestCase"]', 'AI Assistant'),
(63, 'Bài 4: Template và Template Inheritance...', '["Template","base.html","extends","block","render","Template Inheritance","HTML"]', 'AI Assistant'),
(64, 'Bài 5: Static Files và Bootstrap...', '["Static Files","Bootstrap","CSS","JavaScript","load static","Grid System","container-fluid","img"]', 'AI Assistant'),
(65, 'Bài 6: Hoàn thiện giao diện Blog...', '["Avatar","Menu","Footer","CSS","Contact Page","Bootstrap","Layout","block content"]', 'AI Assistant'),
(66, 'Bài 7: Tạo Model và Database...', '["Model","Post","CharField","TextField","DateTimeField","Migration","SQLite","Database"]', 'AI Assistant'),
(67, 'Bài 8: Thao tác dữ liệu với Django ORM...', '["Django Shell","ORM","save","objects.all","objects.get","__str__","TIME_ZONE","CRUD"]', 'AI Assistant'),
(68, 'Bài 9: Trang quản trị Django Admin...', '["Admin","Superuser","admin.py","list_display","list_filter","search_fields","PostAdmin"]', 'AI Assistant'),
(69, 'Bài 10: Liệt kê danh sách...', '["Post.objects.all","order_by","Template","Context","for loop","Blog List","Render"]', 'AI Assistant'),
(70, 'Bài 11: Trang chi tiết bài viết...', '["Detail Page","URL Parameter","objects.get","linebreaks","Template","TestCase"]', 'AI Assistant'),
(71, 'Bài 12: Sử dụng Named URL...', '["Named URL","url tag","urls.py","Template","Dynamic URL","Maintainability"]', 'AI Assistant'),
(72, 'Bài 13: Tùy chỉnh trang lỗi...', '["404","500","handler404","handler500","DEBUG","ALLOWED_HOSTS","error.html"]', 'AI Assistant'),
(73, 'Bài 14: Kiến trúc MVC và MVT...', '["MVC","MVT","Model","Template","View","Request","Response","Architecture"]', 'AI Assistant'),
(74, 'Bài 15: Upload file hình ảnh...', '["ImageField","MEDIA_URL","MEDIA_ROOT","Media","Image Upload","post.image.url"]', 'AI Assistant'),
(75, 'Bài 16: Tạo form đăng ký...', '["RegistrationForm","User","create_user","Validation","CSRF","Register"]', 'AI Assistant'),
(76, 'Bài 17: Login - Logout...', '["Authentication","Login","Logout","auth_views","Template","User Session"]', 'AI Assistant'),
(77, 'Bài 18: Generic View nâng cao...', '["Generic View","ListView","DetailView","Pagination","Class-based View","Refactor"]', 'AI Assistant'),
(78, 'Bài 19: Xử lý bình luận...', '["Comment","ForeignKey","ModelForm","CommentForm","POST","Authentication","comments"]', 'AI Assistant');

-- --------------------------------------------------------
-- NHÓM 4: AI ASSISTANT VÀ LỊCH SỬ CHAT
-- --------------------------------------------------------

INSERT INTO ai_chat_sessions (id, user_id, course_id, lesson_id, title) VALUES
(1, 2, 1, 1, 'Hỏi về lỗi không nhận diện lệnh python'),
(2, 3, 1, 2, 'Tìm hiểu sâu về cơ chế nháy đơn và nháy kép');

INSERT INTO ai_chat_messages (id, session_id, sender, message_text, model_name) VALUES
(1, 1, 'user', 'Mình gõ lệnh python trong cmd báo lỗi "not recognized" thì xử lý sao ạ?', NULL),
(2, 1, 'assistant', 'Lỗi này xuất hiện do bạn chưa thêm đường dẫn cài đặt Python vào biến môi trường Environment Variables (PATH). Hãy tích chọn ô "Add Python to PATH" lúc chạy lại file cài đặt nhé.', 'Qwen2.5-Coder-7B'),
(3, 2, 'user', 'Trong Python dùng dấu nháy đơn hay nháy kép để bọc chuỗi thì tốt hơn?', NULL),
(4, 2, 'assistant', 'Trong Python, cặp nháy đơn và nháy kép có giá trị sử dụng tương đương nhau. Tuy nhiên, nếu chuỗi của bạn chứa dấu nháy đơn, hãy bọc ngoài bằng dấu nháy kép để tránh lỗi cú pháp.', 'Qwen2.5-Coder-7B');

-- --------------------------------------------------------
-- NHÓM 5: QUIZ VÀ KẾT QUẢ KIỂM TRA
-- --------------------------------------------------------

INSERT INTO quizzes (id, lesson_id, title, description, time_limit_seconds, status) VALUES
(1, 2, 'Bài trắc nghiệm khởi động nhanh', 'Kiểm tra kiến thức cơ bản về cách khai báo chuỗi văn bản và gọi hàm xuất dữ liệu.', 300, 'published');

INSERT INTO quiz_questions (id, quiz_id, question_text, code_snippet, difficulty, explanation, sort_order) VALUES
(1, 1, 'Hàm nào sau đây được dùng để in giá trị hoặc dữ liệu ra màn hình console trong Python?', NULL, 'easy', 'Hàm print() là hàm tích hợp sẵn (built-in) của ngôn ngữ Python để thực hiện xuất thông tin.', 1),
(2, 1, 'Đoạn mã lệnh sau đây có kết quả trả về là gì?', 'print("Python " + "AI")', 'easy', 'Phép toán toán tử dấu cộng (+) khi áp dụng trên hai đối tượng chuỗi văn bản sẽ thực thi hành động nối chuỗi nối tiếp nhau.', 2);

INSERT INTO quiz_options (id, question_id, option_label, option_text, is_correct) VALUES
(1, 1, 'A', 'echo()', FALSE),
(2, 1, 'B', 'print()', TRUE),
(3, 1, 'C', 'console.log()', FALSE),
(4, 1, 'D', 'System.out.println()', FALSE),
(5, 2, 'A', 'Python AI', TRUE),
(6, 2, 'B', 'Python+AI', FALSE),
(7, 2, 'C', 'Lỗi cú pháp hệ thống', FALSE);

INSERT INTO quiz_attempts (id, quiz_id, user_id, total_questions, correct_answers, score, started_at, submitted_at) VALUES
(1, 1, 2, 2, 2, 10.00, '2026-06-25 09:00:00', '2026-06-25 09:02:15'),
(2, 1, 3, 2, 1, 5.00, '2026-06-25 09:15:00', '2026-06-25 09:18:40');

INSERT INTO quiz_attempt_answers (id, attempt_id, question_id, selected_option_id, is_correct) VALUES
(1, 1, 1, 2, TRUE), 
(2, 1, 2, 5, TRUE), 
(3, 2, 1, 2, TRUE), 
(4, 2, 2, 6, FALSE);

-- --------------------------------------------------------
-- NHÓM 6: ĐĂNG KÝ KHÓA HỌC VÀ TIẾN ĐỘ HỌC TẬP
-- --------------------------------------------------------

INSERT INTO enrollments (id, user_id, course_id, status, current_lesson_id, progress_percent, completed_lessons_count, last_accessed_at, enrolled_at, completed_at) VALUES
(1, 2, 1, 'active', 2, 17, 1, '2026-06-22 10:20:00', '2026-06-20 08:30:00', NULL),
(2, 3, 1, 'active', 1, 0, 0, '2026-06-21 14:20:00', '2026-06-21 14:00:00', NULL),
(3, 4, 1, 'completed', 6, 100, 6, '2026-06-24 17:30:00', '2026-06-15 09:00:00', '2026-06-24 17:30:00');

INSERT INTO lesson_progress (id, user_id, course_id, lesson_id, last_position_seconds, watched_seconds, duration_seconds, progress_percent, is_completed, completed_at, last_watched_at) VALUES
(1, 2, 1, 1, 600, 600, 600, 100, TRUE, '2026-06-22 10:15:00', '2026-06-22 10:15:00'),
(2, 2, 1, 2, 120, 120, 700, 17, FALSE, NULL, '2026-06-22 10:20:00'),
(3, 3, 1, 1, 450, 450, 600, 75, FALSE, NULL, '2026-06-21 14:20:00');

-- --------------------------------------------------------
-- NHÓM 7: HOẠT ĐỘNG, LIÊN HỆ, THÔNG BÁO VÀ AUDIT
-- --------------------------------------------------------

INSERT INTO learning_activities (id, user_id, activity_type, title, description, related_course_id, related_lesson_id, related_quiz_id, action_url) VALUES
(1, 2, 'video', 'Hoàn thành xem video', 'Đã xem trọn vẹn thời lượng bài hướng dẫn cài đặt môi trường.', 1, 1, NULL, '/learning/1/1'),
(2, 2, 'quiz', 'Nộp bài trắc nghiệm', 'Đạt điểm số tuyệt đối 10.00 tại Bài trắc nghiệm khởi động nhanh.', 1, 2, 1, '/quiz/2/result'),
(3, 2, 'ai', 'Đặt câu hỏi cho Trợ lý ảo AI', 'Yêu cầu hỗ trợ gỡ rối lỗi cấu hình PATH biến hệ thống.', 1, 1, NULL, '/ai-assistant');

INSERT INTO contact_messages (id, full_name, email, phone, subject, message, status) VALUES
(1, 'Trần Minh Hoàng', 'hoangtm@gmail.com', '0914999888', 'Hỏi về lộ trình Python AI', 'Chào ban quản trị, cho mình hỏi khóa học RAG FastAPI có yêu cầu kiến thức nền tảng gì quá sâu không ạ?', 'new');

INSERT INTO notifications (id, user_id, title, content, type, is_read) VALUES
(1, 2, 'Hệ thống AI xử lý hoàn tất!', 'Video bài học số 3 của bạn đã được bóc tách dữ liệu transcript và tóm tắt thành công.', 'ai_pipeline', FALSE),
(2, 3, 'Khuyến mãi khóa học mới', 'Giảm giá ngay 20% khi đăng ký khóa chuyên sâu RAG trong tuần này.', 'promotion', TRUE);

INSERT INTO admin_audit_logs (id, admin_id, action, target_table, target_id) VALUES
(1, 1, 'create', 'courses', 2),
(2, 1, 'process_ai', 'lesson_videos', 4);