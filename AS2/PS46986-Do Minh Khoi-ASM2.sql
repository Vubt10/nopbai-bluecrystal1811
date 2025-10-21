--Y3.Các yêu cầu về chức năng
--1. Thêm thông tin vào các bảng

--Stored Procedure: sp_ThemNguoiDung

CREATE OR ALTER PROCEDURE sp_ThemNguoiDung
    @TenNguoiDung NVARCHAR(50),
    @GioiTinh NVARCHAR(3),
    @DienThoai VARCHAR(15),
    @SoNha NVARCHAR(20),
    @TenDuong NVARCHAR(100),
    @TenPhuong NVARCHAR(100),
    @Quan NVARCHAR(50),
    @Email NVARCHAR(100)
AS
BEGIN
    -- Kiểm tra dữ liệu bắt buộc
    IF (@TenNguoiDung IS NULL OR @TenNguoiDung = ''
        OR @GioiTinh IS NULL OR @GioiTinh = ''
        OR @DienThoai IS NULL OR @DienThoai = ''
        OR @SoNha IS NULL OR @SoNha = ''
        OR @TenDuong IS NULL OR @TenDuong = ''
        OR @TenPhuong IS NULL OR @TenPhuong = ''
        OR @Quan IS NULL OR @Quan = ''
        OR @Email IS NULL OR @Email = '')
    BEGIN
        PRINT N' Lỗi: Vui lòng nhập đầy đủ thông tin người dùng!';
        RETURN;
    END

    -- Thực hiện thêm dữ liệu (KHÔNG bao gồm MaNguoiDung vì là IDENTITY)
    INSERT INTO NGUOIDUNG (TenNguoiDung, GioiTinh, DienThoai, SoNha, TenDuong, TenPhuong, Quan, Email)
    VALUES (@TenNguoiDung, @GioiTinh, @DienThoai, @SoNha, @TenDuong, @TenPhuong, @Quan, @Email);

    PRINT N' Thêm người dùng thành công!';
END;
GO

--Test
-- Thành công
EXEC sp_ThemNguoiDung 
    @TenNguoiDung = N'Nguyễn Văn L',
    @GioiTinh = N'Nam',
    @DienThoai = '0918000022',
    @SoNha = N'22',
    @TenDuong = N'Trần Hưng Đạo',
    @TenPhuong = N'Cầu Ông Lãnh',
    @Quan = N'Quận 1',
    @Email = N'vanl@hcm.com';


-- Lỗi (thiếu email)
EXEC sp_ThemNguoiDung 
    @TenNguoiDung = N'Lê Thị M',
    @GioiTinh = NULL,
    @DienThoai = '0918000033',
    @SoNha = N'33',
    @TenDuong = N'Điện Biên Phủ',
    @TenPhuong = N'Đa Kao',
    @Quan = N'Quận 1',
    @Email = N'lem@hcm.com';
GO

--Stored Procedure: sp_ThemNhaTro
CREATE OR ALTER PROCEDURE sp_ThemNhaTro
    @MaLoaiNha INT,
    @DienTich FLOAT,
    @GiaPhong DECIMAL(18,2),
    @SoNha NVARCHAR(50),
    @TenDuong NVARCHAR(100),
    @TenPhuong NVARCHAR(100),
    @Quan NVARCHAR(50),
    @MoTa NVARCHAR(MAX),
    @NgayDang DATE,
    @MaNguoiDung INT
AS
BEGIN
    SET NOCOUNT ON;

    --  Kiểm tra tham số bắt buộc
    IF @MaLoaiNha IS NULL OR @DienTich IS NULL OR @GiaPhong IS NULL
       OR @SoNha IS NULL OR @TenDuong IS NULL OR @TenPhuong IS NULL
       OR @Quan IS NULL OR @NgayDang IS NULL OR @MaNguoiDung IS NULL
    BEGIN
        PRINT N'Lỗi: Vui lòng nhập đầy đủ thông tin cho nhà trọ!';
        RETURN;
    END;

    --  Nếu hợp lệ thì thêm dữ liệu
    INSERT INTO NHATRO (
        MaLoaiNha, DienTich, GiaPhong, SoNha, TenDuong,
        TenPhuong, Quan, MoTa, NgayDang, MaNguoiDung
    )
    VALUES (
        @MaLoaiNha, @DienTich, @GiaPhong, @SoNha, @TenDuong,
        @TenPhuong, @Quan, @MoTa, @NgayDang, @MaNguoiDung
    );

    PRINT N'Thêm nhà trọ thành công!';
END;
GO
--Test
--Thành công
EXEC sp_ThemNhaTro
    @MaLoaiNha = 2,
    @DienTich = 35.5,
    @GiaPhong = 4200000,
    @SoNha = N'15',
    @TenDuong = N'Nguyễn Kiệm',
    @TenPhuong = N'Phường 3',
    @Quan = N'Gò Vấp',
    @MoTa = N'Phòng mới xây, gần chợ Gò Vấp',
    @NgayDang = '2025-10-18',
    @MaNguoiDung = 5;
--Thất bại
EXEC sp_ThemNhaTro
    @MaLoaiNha = NULL,
    @DienTich = 25.5,
    @GiaPhong = 3500000,
    @SoNha = N'99',
    @TenDuong = N'Lê Lợi',
    @TenPhuong = N'Bến Thành',
    @Quan = N'Quận 1',
    @MoTa = N'Căn hộ mini trung tâm quận 1',
    @NgayDang = '2025-10-18',
    @MaNguoiDung = 2;
--Stored Procedure: sp_ThemDanhGia
GO
CREATE OR ALTER PROCEDURE sp_ThemDanhGia
    @MaNguoiDung INT,
    @MaNhaTro INT,
    @TrangThai NVARCHAR(10),
    @NoiDung NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    --  Kiểm tra dữ liệu bắt buộc
    IF @MaNguoiDung IS NULL OR @MaNhaTro IS NULL OR @TrangThai IS NULL OR @NoiDung IS NULL
    BEGIN
        PRINT N'Lỗi: Vui lòng nhập đầy đủ thông tin đánh giá (người dùng, nhà trọ, trạng thái, nội dung).';
        RETURN;
    END;

    --  Kiểm tra mã người dùng có tồn tại
    IF NOT EXISTS (SELECT 1 FROM NGUOIDUNG WHERE MaNguoiDung = @MaNguoiDung)
    BEGIN
        PRINT N'Lỗi: Mã người dùng không tồn tại trong hệ thống!';
        RETURN;
    END;

    --  Kiểm tra mã nhà trọ có tồn tại
    IF NOT EXISTS (SELECT 1 FROM NHATRO WHERE MaNhaTro = @MaNhaTro)
    BEGIN
        PRINT N'Lỗi: Mã nhà trọ không tồn tại trong hệ thống!';
        RETURN;
    END;

    --  Kiểm tra trùng đánh giá
    IF EXISTS (SELECT 1 FROM DANHGIA WHERE MaNguoiDung = @MaNguoiDung AND MaNhaTro = @MaNhaTro)
    BEGIN
        PRINT N'Lỗi: Người dùng này đã đánh giá nhà trọ này rồi!';
        RETURN;
    END;

    --  Nếu hợp lệ, thêm mới
    INSERT INTO DANHGIA (MaNguoiDung, MaNhaTro, TrangThai, NoiDung)
    VALUES (@MaNguoiDung, @MaNhaTro, @TrangThai, @NoiDung);

    PRINT N'Thêm đánh giá thành công!';
END;
GO

--Test
--Thành công
EXEC sp_ThemDanhGia 
    @MaNguoiDung = 11, 
    @MaNhaTro = 3, 
    @TrangThai = N'LIKE', 
    @NoiDung = N'Phòng sạch sẽ, chủ dễ thương.';

--2. Truy vấn thông tin
--a.Stored Procedure: sp_TimKiemNhaTro
GO
CREATE PROCEDURE sp_TimKiemNhaTro
    @Quan NVARCHAR(50) = NULL,
    @DienTichMin FLOAT = NULL,
    @DienTichMax FLOAT = NULL,
    @NgayDangMin DATE = NULL,
    @NgayDangMax DATE = NULL,
    @GiaMin MONEY = NULL,
    @GiaMax MONEY = NULL,
    @MaLoaiNha INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        N'Cho thuê phòng trọ tại ' 
            + NT.SoNha + N' ' + NT.TenDuong + N', ' + NT.TenPhuong + N', ' + NT.Quan AS [Thông tin phòng trọ],
        FORMAT(NT.DienTich, 'N2', 'vi-VN') + N' m²' AS [Diện tích],
        FORMAT(NT.GiaPhong, 'N0', 'vi-VN') AS [Giá phòng (VNĐ)],
        NT.MoTa AS [Mô tả],
        FORMAT(NT.NgayDang, 'dd-MM-yyyy') AS [Ngày đăng],
        CASE 
            WHEN ND.GioiTinh = N'Nam' THEN N'A. ' + ND.TenNguoiDung
            WHEN ND.GioiTinh = N'Nữ' THEN N'C. ' + ND.TenNguoiDung
            ELSE ND.TenNguoiDung
        END AS [Người liên hệ],
        ND.DienThoai AS [SĐT liên hệ],
        ND.SoNha + N' ' + ND.TenDuong + N', ' + ND.TenPhuong + N', ' + ND.Quan AS [Địa chỉ người liên hệ]
    FROM NHATRO NT
    JOIN NGUOIDUNG ND ON NT.MaNguoiDung = ND.MaNguoiDung
    WHERE 
        (@Quan IS NULL OR NT.Quan = @Quan)
        AND (@DienTichMin IS NULL OR NT.DienTich >= @DienTichMin)
        AND (@DienTichMax IS NULL OR NT.DienTich <= @DienTichMax)
        AND (@NgayDangMin IS NULL OR NT.NgayDang >= @NgayDangMin)
        AND (@NgayDangMax IS NULL OR NT.NgayDang <= @NgayDangMax)
        AND (@GiaMin IS NULL OR NT.GiaPhong >= @GiaMin)
        AND (@GiaMax IS NULL OR NT.GiaPhong <= @GiaMax)
        AND (@MaLoaiNha IS NULL OR NT.MaLoaiNha = @MaLoaiNha);
END;
GO
-- Tìm nhà trọ ở Quận 1, diện tích từ 20 đến 40m2, giá 2-4 triệu
EXEC sp_TimKiemNhaTro 
    @Quan = N'Quận 1', 
    @DienTichMin = 20, 
    @DienTichMax = 40, 
    @GiaMin = 2000000, 
    @GiaMax = 4000000;

-- Tìm loại nhà 3 đăng trong tháng 10/2025
EXEC sp_TimKiemNhaTro 
    @MaLoaiNha = 3, 
    @NgayDangMin = '2025-10-01', 
    @NgayDangMax = '2025-10-31';
GO
--b.fn_TimMaNguoiDung
GO
CREATE FUNCTION fn_TimMaNguoiDung(
    @TenNguoiDung NVARCHAR(100),
    @GioiTinh NVARCHAR(5),
    @DienThoai NVARCHAR(20),
    @SoNha NVARCHAR(20),
    @TenDuong NVARCHAR(100),
    @TenPhuong NVARCHAR(100),
    @Quan NVARCHAR(50),
    @Email NVARCHAR(100)
)
RETURNS INT
AS
BEGIN
    DECLARE @MaNguoiDung INT;

    SELECT @MaNguoiDung = MaNguoiDung
    FROM NGUOIDUNG
    WHERE 
        TenNguoiDung = @TenNguoiDung
        AND GioiTinh = @GioiTinh
        AND DienThoai = @DienThoai
        AND SoNha = @SoNha
        AND TenDuong = @TenDuong
        AND TenPhuong = @TenPhuong
        AND Quan = @Quan
        AND Email = @Email;

    RETURN @MaNguoiDung;
END;
GO
-- Ví dụ: Tìm mã người dùng của Nguyễn Văn A
SELECT dbo.fn_TimMaNguoiDung(
    N'Nguyễn Văn A',  -- TenNguoiDung
    N'Nam',           -- GioiTinh
    '0918000001',     -- DienThoai
    '12',             -- SoNha
    N'Nguyễn Thị Minh Khai', -- TenDuong
    N'Bến Nghé',      -- TenPhuong
    N'Quận 1',        -- Quan
    'vana@hcm.com'    -- Email
) AS MaNguoiDung;

--c.fn_ThongKeDanhGiaNhaTro
GO
CREATE FUNCTION fn_ThongKeDanhGiaNhaTro(@MaNhaTro INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        SUM(CASE WHEN TrangThai = N'LIKE' THEN 1 ELSE 0 END) AS TongLike,
        SUM(CASE WHEN TrangThai = N'DISLIKE' THEN 1 ELSE 0 END) AS TongDislike
    FROM DANHGIA
    WHERE MaNhaTro = @MaNhaTro
);
GO
-- Ví dụ: xem tổng LIKE và DISLIKE của nhà trọ có mã 2
SELECT * FROM dbo.fn_ThongKeDanhGiaNhaTro(2);
--c. v_Top10NhaTroLikeNhieuNhat
GO
CREATE OR ALTER VIEW v_Top10NhaTroLikeNhieuNhat
AS
SELECT TOP 10
    NT.DienTich,
    NT.GiaPhong,
    NT.MoTa,
    NT.NgayDang,
    ND.TenNguoiDung AS [Tên người liên hệ],
    ND.SoNha + N' ' + ND.TenDuong + N', ' + ND.TenPhuong + N', ' + ND.Quan AS [Địa chỉ],
    ND.DienThoai AS [Điện thoại],
	ND.Email AS [Email],
    COUNT(DG.TrangThai) AS [Số lượng LIKE]
FROM NHATRO NT
JOIN NGUOIDUNG ND ON NT.MaNguoiDung = ND.MaNguoiDung
JOIN DANHGIA DG ON NT.MaNhaTro = DG.MaNhaTro
WHERE DG.TrangThai = N'LIKE'
GROUP BY 
    NT.DienTich, 
    NT.GiaPhong, 
    NT.MoTa, 
    NT.NgayDang,
    ND.TenNguoiDung,
    ND.SoNha, ND.TenDuong, ND.TenPhuong, ND.Quan,
    ND.DienThoai,
	ND.Email
ORDER BY [Số lượng LIKE] DESC;
GO
--Test
SELECT * FROM v_Top10NhaTroLikeNhieuNhat;
--d. sp_ThongTinDanhGiaTheoNhaTro
GO
CREATE PROCEDURE sp_ThongTinDanhGiaTheoNhaTro
    @MaNhaTro INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        NT.MaNhaTro,
        ND.TenNguoiDung AS [Tên người đánh giá],
        DG.TrangThai AS [Trạng thái],
        DG.NoiDung AS [Nội dung đánh giá]
    FROM DANHGIA DG
        JOIN NGUOIDUNG ND ON DG.MaNguoiDung = ND.MaNguoiDung
        JOIN NHATRO NT ON DG.MaNhaTro = NT.MaNhaTro
    WHERE NT.MaNhaTro = @MaNhaTro;
END;
GO
--Test
EXEC sp_ThongTinDanhGiaTheoNhaTro @MaNhaTro = 3;
--3.Xoá thông tin
--1.SP: Xóa nhà trọ có số lượng DISLIKE lớn hơn giá trị truyền vào
GO
CREATE OR ALTER PROCEDURE sp_XoaNhaTroTheoDislike
    @SoLuongDislike INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        --  Tìm danh sách nhà trọ cần xóa
        DECLARE @DanhSach TABLE (MaNhaTro INT);

        INSERT INTO @DanhSach (MaNhaTro)
        SELECT MaNhaTro
        FROM DANHGIA
        GROUP BY MaNhaTro
        HAVING SUM(CASE WHEN TrangThai = 'DISLIKE' THEN 1 ELSE 0 END) > @SoLuongDislike;

        --  Kiểm tra có nhà trọ nào đủ điều kiện không
        IF NOT EXISTS (SELECT 1 FROM @DanhSach)
        BEGIN
            PRINT N' Không có nhà trọ nào có số lượng DISLIKE lớn hơn ' + CAST(@SoLuongDislike AS NVARCHAR(10));
            ROLLBACK TRANSACTION;
            RETURN;
        END

        --  Xóa thông tin đánh giá trước
        DELETE FROM DANHGIA
        WHERE MaNhaTro IN (SELECT MaNhaTro FROM @DanhSach);

        --  Xóa thông tin nhà trọ
        DELETE FROM NHATRO
        WHERE MaNhaTro IN (SELECT MaNhaTro FROM @DanhSach);

        COMMIT TRANSACTION;
        PRINT N' Đã xóa thành công các nhà trọ có số lượng DISLIKE lớn hơn ' + CAST(@SoLuongDislike AS NVARCHAR(10));
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N' Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

--Test
EXEC sp_XoaNhaTroTheoDislike @SoLuongDislike = 100;
--2. sp_XoaNhaTroTheoThoiGian
GO
CREATE PROCEDURE sp_XoaNhaTroTheoThoiGian
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 🧩 Kiểm tra tham số đầu vào
    IF @TuNgay IS NULL OR @DenNgay IS NULL
    BEGIN
        PRINT N' Lỗi: Vui lòng nhập đầy đủ khoảng thời gian cần xóa (Từ ngày, Đến ngày).';
        RETURN;
    END;

    IF @TuNgay > @DenNgay
    BEGIN
        PRINT N' Lỗi: Ngày bắt đầu không được lớn hơn ngày kết thúc.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 🧩 Tìm danh sách nhà trọ cần xóa
        DECLARE @DanhSach TABLE (MaNhaTro INT);

        INSERT INTO @DanhSach (MaNhaTro)
        SELECT MaNhaTro
        FROM NHATRO
        WHERE NgayDang BETWEEN @TuNgay AND @DenNgay;

        --  Kiểm tra có dữ liệu hay không
        IF NOT EXISTS (SELECT 1 FROM @DanhSach)
        BEGIN
            PRINT N' Không có nhà trọ nào được đăng trong khoảng thời gian từ '
                  + CONVERT(NVARCHAR(10), @TuNgay, 105)
                  + N' đến '
                  + CONVERT(NVARCHAR(10), @DenNgay, 105);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        --  Xóa thông tin đánh giá trước
        DELETE FROM DANHGIA
        WHERE MaNhaTro IN (SELECT MaNhaTro FROM @DanhSach);

        --  Xóa thông tin nhà trọ
        DELETE FROM NHATRO
        WHERE MaNhaTro IN (SELECT MaNhaTro FROM @DanhSach);

        COMMIT TRANSACTION;
        PRINT N' Đã xóa thành công các nhà trọ được đăng từ '
              + CONVERT(NVARCHAR(10), @TuNgay, 105)
              + N' đến '
              + CONVERT(NVARCHAR(10), @DenNgay, 105);
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N' Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
--Test
--  Trường hợp có dữ liệu
EXEC sp_XoaNhaTroTheoThoiGian 
    @TuNgay = '2024-01-01', 
    @DenNgay = '2024-12-31';

--  Trường hợp không có dữ liệu
EXEC sp_XoaNhaTroTheoThoiGian 
    @TuNgay = '2030-01-01', 
    @DenNgay = '2030-12-31';

--  Trường hợp nhập sai logic
EXEC sp_XoaNhaTroTheoThoiGian 
    @TuNgay = '2025-12-31', 
    @DenNgay = '2025-01-01';
GO
--Y4.Yêu cầu quản trị CSDL
-- Tạo login cho admin
CREATE LOGIN admin_nhatro WITH PASSWORD = 'Admin@123';

-- Tạo login cho user thường
CREATE LOGIN user_nhatro WITH PASSWORD = 'User@123';

-- Tạo user trong database từ login
CREATE USER admin_nhatro FOR LOGIN admin_nhatro;
CREATE USER user_nhatro FOR LOGIN user_nhatro;

-- Cấp toàn quyền quản trị trên database cho admin_nhatro
ALTER ROLE db_owner ADD MEMBER admin_nhatro;

-- Cấp quyền thao tác dữ liệu cho user_nhatro
GRANT SELECT, INSERT, UPDATE, DELETE ON DATABASE::QLNhaTro_DoMinhKhoi TO user_nhatro;

-- Cấp quyền thực thi SP và Function cho user_nhatro
GRANT EXECUTE TO user_nhatro;























