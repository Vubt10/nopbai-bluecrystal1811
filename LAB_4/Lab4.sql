--Bài 1:

--Sử dụng CASE và IF…ELSE trong cơ sở dữ liệu QLDA.

-- Hiển thị TenNV (thêm tiền tố Mr/Ms tùy giới tính)
SELECT 
    CASE 
        WHEN PHAI = N'Nữ' THEN 'Ms. ' + TENNV
        ELSE 'Mr. ' + TENNV
    END AS TenNV
FROM NHANVIEN;

--Tính thuế theo lương
SELECT 
    TENNV,
    LUONG,
    CASE 
        WHEN LUONG < 25000 THEN LUONG*0.1
        WHEN LUONG < 30000 THEN LUONG*0.12
        WHEN LUONG < 40000 THEN LUONG*0.15
        WHEN LUONG < 50000 THEN LUONG*0.20
        ELSE LUONG*0.25
    END AS Thue
FROM NHANVIEN;

--Tăng lương và phân loại
SELECT 
    TENNV,
    CASE 
        WHEN LUONG < (SELECT AVG(LUONG) 
                      FROM NHANVIEN B 
                      WHERE B.PHG = A.PHG)
             THEN 'TangLuong'
        ELSE 'KhongTangLuong'
    END AS TinhTrang,
    CASE 
        WHEN LUONG < (SELECT AVG(LUONG) 
                      FROM NHANVIEN B 
                      WHERE B.PHG = A.PHG)
             THEN 'NhanVien'
        ELSE 'TruongPhong'
    END AS XepLoai
FROM NHANVIEN A;

--Bài 2:

--Dùng vòng lặp (WHILE) để liệt kê nhân viên có MaNV là số chẵn.

--Tất cả MaNV chẵn
DECLARE @id INT = 1;
WHILE @id <= (SELECT MAX(CAST(MANV AS INT)) FROM NHANVIEN)
BEGIN
    IF @id % 2 = 0
        SELECT HONV, TENLOT, TENNV, MANV
        FROM NHANVIEN
        WHERE MANV = RIGHT('000' + CAST(@id AS VARCHAR),3);
    SET @id += 1;
END;

--Chẵn nhưng bỏ MaNV = 4
DECLARE @id INT = 1;
WHILE @id <= (SELECT MAX(CAST(MANV AS INT)) FROM NHANVIEN)
BEGIN
    IF @id % 2 = 0 AND @id <> 4
        SELECT HONV, TENLOT, TENNV, MANV
        FROM NHANVIEN
        WHERE MANV = RIGHT('000' + CAST(@id AS VARCHAR),3);
    SET @id += 1;
END;

--Bài 3:

--Quản lý lỗi với TRY…CATCH và RAISERROR.

--Thêm dữ liệu thành công và thất bại
BEGIN TRY
    INSERT INTO PHONGBAN(TENPHG, MAPHG) VALUES(N'Kinh Doanh', '9');
    PRINT N'Thêm dữ liệu thành công';
END TRY
BEGIN CATCH
    PRINT N'Thêm dữ liệu thất bại';
END CATCH;

--Chèn sai dữ liệu
BEGIN TRY
    INSERT INTO PHONGBAN(MAPHG, TENPHG) VALUES('P09', N'Kinh Doanh');
    PRINT N'Thêm dữ liệu thành công';
END TRY
BEGIN CATCH
    PRINT N'Thêm dữ liệu thất bại';
END CATCH;

--Chia cho 0 và báo lỗi
DECLARE @chia INT = 10;
BEGIN TRY
    SELECT @chia / 0;
END TRY
BEGIN CATCH
    RAISERROR (N'Lỗi chia cho 0',16,1);
END CATCH;

