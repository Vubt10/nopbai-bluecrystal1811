-- Bài 1:

-- Tổng giờ làm việc theo đề án

-- Cách 1: CAST
SELECT DA.TENDA,
       CAST(SUM(PC.THOIGIAN) AS DECIMAL(10,2)) AS TongGio_DEC,
       CAST(SUM(PC.THOIGIAN) AS VARCHAR(20))   AS TongGio_VARCHAR
FROM DeAn DA
JOIN PhanCong PC ON DA.MADA = PC.MADA
GROUP BY DA.TENDA;

-- Cách 2: CONVERT
SELECT DA.TENDA,
       CONVERT(DECIMAL(10,2), SUM(PC.THOIGIAN)) AS TongGio_DEC,
       CONVERT(VARCHAR(20), SUM(PC.THOIGIAN))   AS TongGio_VARCHAR
FROM DeAn DA
JOIN PhanCong PC ON DA.MADA = PC.MADA
GROUP BY DA.TENDA;

-- Lương trung bình theo phòng ban
-- CAST
SELECT PB.TENPHG,
       CAST(AVG(NV.LUONG) AS DECIMAL(10,2)) AS LuongTB_DEC,
       REPLACE(CONVERT(VARCHAR,CAST(AVG(NV.LUONG) AS MONEY),1),'.00','') AS LuongTB_VARCHAR
FROM PhongBan PB
JOIN NhanVien NV ON PB.MAPHG = NV.PHG
GROUP BY PB.TENPHG;

-- CONVERT
SELECT PB.TENPHG,
       CONVERT(DECIMAL(10,2), AVG(NV.LUONG)) AS LuongTB_DEC,
       REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,AVG(NV.LUONG)),1),'.00','') AS LuongTB_VARCHAR
FROM PhongBan PB
JOIN NhanVien NV ON PB.MAPHG = NV.PHG
GROUP BY PB.TENPHG;

--Bài 2:

--1. Tổng giờ làm việc theo đề án (CEILING, FLOOR, ROUND)

SELECT DA.TENDA,
       CEILING(SUM(PC.THOIGIAN)) AS Gio_CEILING,
       FLOOR(SUM(PC.THOIGIAN))   AS Gio_FLOOR,
       ROUND(SUM(PC.THOIGIAN),2) AS Gio_ROUND2
FROM DeAn DA
JOIN PhanCong PC ON DA.MADA = PC.MADA
GROUP BY DA.TENDA;

--2. Nhân viên có lương > lương TB phòng “Nghiên cứu” (làm tròn 2 số)

SELECT NV.HONV, NV.TENLOT, NV.TENNV, NV.LUONG
FROM NhanVien NV
WHERE NV.LUONG >
      (SELECT ROUND(AVG(NV2.LUONG),2)
       FROM NhanVien NV2
       JOIN PhongBan PB ON NV2.PHG = PB.MAPHG
       WHERE PB.TENPHG = N'Nghiên cứu');

--Bài 3:

--1. Nhân viên có >2 thân nhân, định dạng theo yêu cầu

SELECT 
    UPPER(HONV)  AS HONV,                 -- họ in hoa
    LOWER(TENLOT) AS TENLOT,              -- tên lót thường
    STUFF(LOWER(TENNV),2,1,UPPER(SUBSTRING(TENNV,2,1))) AS TENNV, -- ký tự 2 in hoa
    -- chỉ lấy tên đường: bỏ số nhà và phần sau dấu phẩy
    LTRIM(
        SUBSTRING(
            DCHI,
            PATINDEX('%[^0-9 ]%', DCHI),                           -- vị trí ký tự đầu tiên KHÔNG phải số/space
            CASE WHEN CHARINDEX(',', DCHI) > 0                      -- nếu có dấu phẩy
                 THEN CHARINDEX(',', DCHI) - PATINDEX('%[^0-9 ]%', DCHI)
                 ELSE LEN(DCHI) - PATINDEX('%[^0-9 ]%', DCHI) + 1
            END
        )
    ) AS Duong
FROM dbo.NhanVien NV
WHERE (
        SELECT COUNT(*) 
        FROM dbo.ThanNhan TN 
        WHERE TN.MA_NVIEN = NV.MANV
      ) > 2;

--2. Phòng ban đông nhân viên nhất, thay tên trưởng phòng = 'Fpoly'

SELECT TOP 1
       PB.TENPHG,
       'Fpoly' AS TruongPhong
FROM PhongBan PB
JOIN NhanVien NV ON PB.MAPHG = NV.PHG
GROUP BY PB.TENPHG
ORDER BY COUNT(NV.MANV) DESC;

--Bài 4: 

--1.Nhân viên có năm sinh từ 1960 đến 1965
SELECT HONV, TENLOT, TENNV, NGSINH
FROM dbo.NhanVien
WHERE YEAR(NGSINH) BETWEEN 1960 AND 1965;

--2.Tính tuổi hiện tại của mỗi nhân viên
SELECT HONV, TENLOT, TENNV,
       DATEDIFF(YEAR, NGSINH, GETDATE()) AS TUOI
FROM dbo.NhanVien;

--3.Cho biết thứ trong tuần mà nhân viên sinh
SELECT HONV, TENLOT, TENNV,
       DATENAME(WEEKDAY, NGSINH) AS ThuSinh
FROM dbo.NhanVien;

--4. Thống kê số lượng nhân viên, tên trưởng phòng, ngày nhận chức trưởng phòng
SELECT 
    PB.TENPHG,
    NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS TruongPhong,
    COUNT(NV2.MANV) AS SoLuongNV,
    FORMAT(PB.NG_NHANCHUC, 'dd-MM-yy') AS NgayNhanChuc
FROM dbo.PhongBan PB
LEFT JOIN dbo.NhanVien NV  ON PB.TRPHG = NV.MANV      -- trưởng phòng
LEFT JOIN dbo.NhanVien NV2 ON PB.MAPHG = NV2.PHG      -- nhân viên phòng
GROUP BY PB.TENPHG, NV.HONV, NV.TENLOT, NV.TENNV, PB.NG_NHANCHUC;

