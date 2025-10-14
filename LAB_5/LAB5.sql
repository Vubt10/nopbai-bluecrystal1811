--Bài 1:
CREATE PROCEDURE sp_XinChao
    @ten NVARCHAR(50)
AS
BEGIN
    PRINT N'Xin chào ' + @ten;
END;
GO

EXEC sp_XinChao N'Khôi Đỗ';

GO
CREATE PROCEDURE sp_TinhTong
    @s1 FLOAT,
    @s2 FLOAT
AS
BEGIN
    DECLARE @tg FLOAT;
    SET @tg = @s1 + @s2;
    PRINT N'Tổng là: ' + CAST(@tg AS NVARCHAR(30));
END;
GO

EXEC sp_TinhTong 12.5, 7.5;

GO
CREATE PROCEDURE sp_TongChan
    @n INT
AS
BEGIN
    DECLARE @i INT = 1, @tong INT = 0;

    WHILE @i <= @n
    BEGIN
        IF @i % 2 = 0
            SET @tong = @tong + @i;
        SET @i = @i + 1;
    END

    PRINT N'Tổng các số chẵn từ 1 đến ' + CAST(@n AS NVARCHAR(10)) + N' là: ' + CAST(@tong AS NVARCHAR(10));
END;
GO

EXEC sp_TongChan 10;

GO
CREATE PROCEDURE sp_UCLN
    @a INT,
    @b INT
AS
BEGIN
    DECLARE @a1 INT, @b1 INT, @temp INT;

    -- Đảm bảo A >= B
    IF @a > @b
    BEGIN
        SET @a1 = @a;
        SET @b1 = @b;
    END
    ELSE
    BEGIN
        SET @a1 = @b;
        SET @b1 = @a;
    END

    -- Thuật toán Euclid
    WHILE @b1 <> 0
    BEGIN
        SET @temp = @a1 % @b1;
        SET @a1 = @b1;
        SET @b1 = @temp;
    END

    PRINT N'Ước chung lớn nhất là: ' + CAST(@a1 AS NVARCHAR(10));
END;
GO

EXEC sp_UCLN 12, 18;

--Bài 2:
go
CREATE PROCEDURE sp_TimNhanVienTheoMa
    @Manv CHAR(9)
AS
BEGIN
    SELECT *
    FROM NHANVIEN
    WHERE MANV = @Manv;
END;
GO

EXEC sp_TimNhanVienTheoMa '001';

go
CREATE PROCEDURE sp_SoLuongNV_TheoDeAn
    @MaDa INT
AS
BEGIN
    SELECT COUNT(DISTINCT MA_NVIEN) AS SoLuongNhanVien
    FROM PHANCONG
    WHERE MADA = @MaDa;
END;
GO

EXEC sp_SoLuongNV_TheoDeAn 1;

go
CREATE PROCEDURE sp_SoLuongNV_TheoDeAn_DiaDiem
    @MaDa INT,
    @Ddiem_DA NVARCHAR(50)
AS
BEGIN
    SELECT COUNT(DISTINCT PC.MA_NVIEN) AS SoLuongNhanVien
    FROM PHANCONG PC
        JOIN DEAN DA ON PC.MADA = DA.MADA
    WHERE DA.MADA = @MaDa
      AND DA.DDIEM_DA = @Ddiem_DA;
END;
GO

EXEC sp_SoLuongNV_TheoDeAn_DiaDiem 10, N'Hà Nội';

go
CREATE or alter PROC sp_NhanVien_TheoTruongPhong_KhongThanNhan
    @Trphg CHAR(9)
AS
BEGIN
    SET NOCOUNT ON;

    -- Nhân viên có trưởng phòng là @Trphg
    PRINT N'===== DANH SÁCH NHÂN VIÊN CÓ TRƯỞNG PHÒNG LÀ ' + @Trphg + N' =====';
    SELECT *
    FROM NHANVIEN 
    WHERE MA_NQL = @Trphg;

    -- Dòng ngăn cách
    PRINT CHAR(13) + CHAR(10) + N'===== DANH SÁCH NHÂN VIÊN KHÔNG CÓ THÂN NHÂN =====';

    -- Nhân viên không có thân nhân
    SELECT *
    FROM NHANVIEN 
    WHERE MANV NOT IN (SELECT TN.MA_NVIEN FROM THANNHAN TN);
END;


EXEC sp_NhanVien_TheoTruongPhong_KhongThanNhan '005';


go
CREATE PROCEDURE sp_KiemTraNV_ThuocPhong
    @Manv CHAR(9),
    @Mapb INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM NHANVIEN
        WHERE MANV = @Manv AND MA_NQL = @Mapb
    )
        PRINT N'Nhân viên ' + @Manv + N' thuộc phòng ban ' + CAST(@Mapb AS NVARCHAR(10));
    ELSE
        PRINT N'Nhân viên ' + @Manv + N' KHÔNG thuộc phòng ban ' + CAST(@Mapb AS NVARCHAR(10));
END;
GO

EXEC sp_KiemTraNV_ThuocPhong '004', 5;

--Bài 3:
go
CREATE PROC sp_ThemPhongBan
    @Maphg INT,
    @Tenphg NVARCHAR(50),
    @Trphg CHAR(9) = NULL,
    @Ng_NhanChuc DATE = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM PHONGBAN WHERE MAPHG = @Maphg)
    BEGIN
        PRINT N'Thêm thất bại: Mã phòng ban đã tồn tại!';
        RETURN;
    END

    INSERT INTO PHONGBAN(MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
    VALUES (@Maphg, @Tenphg, @Trphg, @Ng_NhanChuc);

    PRINT N'Thêm phòng ban thành công!';
END;

EXEC sp_ThemPhongBan 10, N'CNTT', NULL, NULL;

go
CREATE PROC sp_CapNhatPhongBan
AS
BEGIN
    UPDATE PHONGBAN
    SET TENPHG = N'IT'
    WHERE TENPHG = N'CNTT';

    IF @@ROWCOUNT = 0
        PRINT N'Không tìm thấy phòng ban CNTT để cập nhật!';
    ELSE
        PRINT N'Đã cập nhật phòng ban CNTT thành IT thành công!';
END;

EXEC sp_CapNhatPhongBan;

go
CREATE PROC sp_ThemNhanVien
    @Honv NVARCHAR(15),
    @Tenlot NVARCHAR(15),
    @Tennv NVARCHAR(15),
    @Manv CHAR(9),
    @NgSinh DATE,
    @Dchi NVARCHAR(100),
    @Phai NVARCHAR(3),
    @Luong FLOAT,
    @Phg INT
AS
BEGIN
    DECLARE @Tuoi INT, @MaNQL CHAR(9);

    -- Kiểm tra phòng ban có tồn tại và có tên IT không
    IF NOT EXISTS (SELECT 1 FROM PHONGBAN WHERE MAPHG = @Phg AND TENPHG = N'IT')
    BEGIN
        PRINT N'Thêm thất bại: Phòng ban IT không tồn tại hoặc mã phòng không đúng!';
        RETURN;
    END

    -- Xác định người quản lý theo lương
    SET @MaNQL = CASE WHEN @Luong < 25000 THEN '009' ELSE '005' END;

    -- Tính tuổi
    SET @Tuoi = DATEDIFF(YEAR, @NgSinh, GETDATE());

    -- Kiểm tra điều kiện tuổi theo giới tính
    IF (@Phai = N'Nam' AND (@Tuoi < 18 OR @Tuoi > 65))
    BEGIN
        PRINT N'Thêm thất bại: Nam phải từ 18 đến 65 tuổi!';
        RETURN;
    END
    ELSE IF (@Phai = N'Nữ' AND (@Tuoi < 18 OR @Tuoi > 60))
    BEGIN
        PRINT N'Thêm thất bại: Nữ phải từ 18 đến 60 tuổi!';
        RETURN;
    END

    -- Thêm nhân viên
    INSERT INTO NHANVIEN (HONV, TENLOT, TENNV, MANV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
    VALUES (@Honv, @Tenlot, @Tennv, @Manv, @NgSinh, @Dchi, @Phai, @Luong, @MaNQL, @Phg);

    PRINT N'Thêm nhân viên thành công!';
END;

EXEC sp_ThemNhanVien 
    @Honv = N'Đỗ',
    @Tenlot = N'Minh',
    @Tennv = N'Khôi',
    @Manv = '100',
    @NgSinh = '1995-05-10',
    @Dchi = N'123 Lê Lợi, TP HCM',
    @Phai = N'Nam',
    @Luong = 24000,
    @Phg = 10;












