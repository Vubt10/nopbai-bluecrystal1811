--Bài 1:
--Hàm: Nhập vào Mã NV → Trả về tuổi của nhân viên
CREATE FUNCTION fn_TuoiNhanVien(@MaNV INT)
RETURNS INT
AS
BEGIN
    DECLARE @Tuoi INT;

    SELECT @Tuoi = DATEDIFF(YEAR, NGSINH, GETDATE())
    FROM NHANVIEN
    WHERE MANV = @MaNV;

    RETURN @Tuoi;
END;
GO

--Kiểm tra:
SELECT dbo.fn_TuoiNhanVien(003) AS Tuoi;

GO
--Hàm: Nhập vào Mã NV → Trả về số lượng đề án đã tham gia
CREATE FUNCTION fn_SoLuongDeAn(@MaNV INT)
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;

    SELECT @SoLuong = COUNT(DISTINCT MADA)
    FROM PHANCONG
    WHERE MA_NVIEN = @MaNV;

    RETURN @SoLuong;
END;
GO

--Kiểm tra:
SELECT dbo.fn_SoLuongDeAn(003) AS SoLuongDeAn;

GO
--Hàm: Truyền tham số "Nam" hoặc "Nữ" → Trả về số lượng nhân viên theo phái
CREATE FUNCTION fn_SoLuongTheoPhai(@Phai NVARCHAR(3))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;

    SELECT @SoLuong = COUNT(*)
    FROM NHANVIEN
    WHERE PHAI = @Phai;

    RETURN @SoLuong;
END;
GO

-- Kiểm tra:
SELECT dbo.fn_SoLuongTheoPhai(N'Nam') AS SL_Nam,
       dbo.fn_SoLuongTheoPhai(N'Nữ') AS SL_Nu;

GO
--Hàm: Truyền vào tên phòng → Trả về danh sách nhân viên có lương > trung bình phòng đó
CREATE FUNCTION fn_NVLuongTrenTB(@TenPhong NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT N.HONV, N.TENLOT, N.TENNV, N.LUONG
    FROM NHANVIEN N
    JOIN PHONGBAN P ON N.PHG = P.MAPHG
    WHERE P.TENPHG = @TenPhong
      AND N.LUONG > (
          SELECT AVG(LUONG)
          FROM NHANVIEN NV2
          WHERE NV2.PHG = P.MAPHG
      )
);
GO
--Kiểm tra:
SELECT * FROM dbo.fn_NVLuongTrenTB(N'Nghiên cứu');

--Hàm: Truyền vào Mã phòng → Trả về tên phòng, tên trưởng phòng, và số lượng đề án phòng đó chủ trì
GO
CREATE FUNCTION fn_ThongTinPhong(@MaPhong INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        P.TENPHG AS TenPhong,
        (N.HONV + ' ' + N.TENLOT + ' ' + N.TENNV) AS TruongPhong,
        COUNT(D.MADA) AS SoLuongDeAnChuTri
    FROM PHONGBAN P
    JOIN NHANVIEN N ON P.TRPHG = N.MANV
    LEFT JOIN DEAN D ON D.PHONG = P.MAPHG
    WHERE P.MAPHG = @MaPhong
    GROUP BY P.TENPHG, N.HONV, N.TENLOT, N.TENNV
);
GO

--Kiểm tra:
SELECT * FROM dbo.fn_ThongTinPhong(4);

--Bài 2:
--View: Hiển thị Họ nhân viên, Tên nhân viên, Tên phòng, Địa điểm phòng
GO
CREATE VIEW v_ThongTinNhanVien_Phong
AS
SELECT 
    NV.HONV,
    NV.TENNV,
    PB.TENPHG,
    DP.DIADIEM AS DiaDiemPhg
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
JOIN DIADIEM_PHG DP ON PB.MAPHG = DP.MAPHG;
GO

--Kiểm tra:
SELECT * FROM v_ThongTinNhanVien_Phong;

--View: Hiển thị Tên nhân viên, Lương, Tuổi
GO
CREATE VIEW v_LuongTuoiNhanVien
AS
SELECT 
    (NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV) AS HoTen,
    NV.LUONG,
    DATEDIFF(YEAR, NV.NGSINH, GETDATE()) AS Tuoi
FROM NHANVIEN NV;
GO

--Kiểm tra:
SELECT * FROM v_LuongTuoiNhanVien;

--View: Hiển thị Tên phòng ban và họ tên trưởng phòng của phòng có nhiều nhân viên nhất
GO
CREATE VIEW v_PhongDongNhanVienNhat
AS
SELECT TOP 1
    PB.TENPHG AS TenPhongBan,
    (TP.HONV + ' ' + TP.TENLOT + ' ' + TP.TENNV) AS TruongPhong,
    COUNT(NV.MANV) AS SoLuongNhanVien
FROM PHONGBAN PB
JOIN NHANVIEN TP ON PB.TRPHG = TP.MANV
JOIN NHANVIEN NV ON NV.PHG = PB.MAPHG
GROUP BY PB.TENPHG, TP.HONV, TP.TENLOT, TP.TENNV
ORDER BY COUNT(NV.MANV) DESC;
GO

--Kiểm tra:
SELECT * FROM v_PhongDongNhanVienNhat;







