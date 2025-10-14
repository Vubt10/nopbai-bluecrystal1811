--Bài 1:
CREATE TRIGGER trg_NhanVien_Luong
ON NHANVIEN
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM INSERTED WHERE LUONG <= 15000)
    BEGIN
        PRINT N'Lỗi: Lương phải > 15000!';
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
INSERT INTO NHANVIEN (HONV, TENLOT, TENNV, MANV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
VALUES (N'Lê', N'Văn', N'B', '012', '1990-05-10', N'Đà Nẵng', N'Nam', 12000, '005', 1);


GO
CREATE or alter TRIGGER trg_NhanVien_Tuoi
ON NHANVIEN
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM INSERTED
        WHERE DATEDIFF(YEAR, NGSINH, GETDATE()) NOT BETWEEN 18 AND 65
    )
    BEGIN
        PRINT N'Lỗi: Tuổi nhân viên phải trong khoảng 18 đến 65!';
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
-- Trường hợp SAI (Tuổi 16 – quá nhỏ)
INSERT INTO NHANVIEN 
(HONV, TENLOT, TENNV, MANV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
VALUES 
(N'Trần', N'Minh', N'Khang', '022', '2009-05-10', N'Hà Nội', N'Nam', 25000, '005', 1);

-- Trường hợp SAI (Tuổi 70 – quá lớn)
INSERT INTO NHANVIEN 
(HONV, TENLOT, TENNV, MANV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
VALUES 
(N'Lê', N'Thị', N'Hồng', '023', '1955-02-20', N'Huế', N'Nữ', 26000, '009', 1);


GO
CREATE TRIGGER trg_KhongCapNhat_TPHCM
ON NHANVIEN
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM DELETED D
        JOIN INSERTED I ON D.MANV = I.MANV
        WHERE D.DCHI LIKE N'%TP HCM%'
    )
    BEGIN
        PRINT N'Lỗi: Không được cập nhật nhân viên ở TP HCM!';
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

UPDATE NHANVIEN
SET LUONG = 50000
WHERE DCHI LIKE N'%TP HCM%';

--Bài 2:
GO
CREATE TRIGGER trg_AfterInsert_NhanVien
ON NHANVIEN
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TongNam INT, @TongNu INT;

    SELECT 
        @TongNam = COUNT(*) 
        FROM NHANVIEN 
        WHERE PHAI = N'Nam';

    SELECT 
        @TongNu = COUNT(*) 
        FROM NHANVIEN 
        WHERE PHAI = N'Nữ';

    PRINT N' Sau khi thêm nhân viên:';
    PRINT N'- Tổng số nhân viên Nam: ' + CAST(@TongNam AS NVARCHAR(10));
    PRINT N'- Tổng số nhân viên Nữ: ' + CAST(@TongNu AS NVARCHAR(10));
END;
INSERT INTO NHANVIEN (HONV, TENLOT, TENNV, MANV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
VALUES (N'Lê', N'Văn', N'Tuấn', '030', '1995-10-10', N'Hà Nội', N'Nam', 20000, '005', 1);
INSERT INTO NHANVIEN (MANV, HONV, TENLOT, TENNV, NGSINH, PHAI, DCHI, LUONG, PHG)
VALUES ('011', N'Nguyễn', N'Thị', N'Mai', '1995-04-12', N'Nữ', N'Hà Nội', 30000, 1);

GO
CREATE TRIGGER trg_AfterUpdate_Phai
ON NHANVIEN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem có cập nhật cột PHAI không
    IF UPDATE(PHAI)
    BEGIN
        DECLARE @TongNam INT, @TongNu INT;

        SELECT 
            @TongNam = COUNT(*) 
            FROM NHANVIEN 
            WHERE PHAI = N'Nam';

        SELECT 
            @TongNu = COUNT(*) 
            FROM NHANVIEN 
            WHERE PHAI = N'Nữ';

        PRINT N' Sau khi cập nhật giới tính:';
        PRINT N'- Tổng số nhân viên Nam: ' + CAST(@TongNam AS NVARCHAR(10));
        PRINT N'- Tổng số nhân viên Nữ: ' + CAST(@TongNu AS NVARCHAR(10));
    END
END;

UPDATE NHANVIEN
SET PHAI = N'Nữ'
WHERE MANV = '030';

GO
CREATE TRIGGER trg_AfterDelete_DeAn
ON DEAN
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    PRINT N' Sau khi xóa đề án: Tổng số đề án mà mỗi nhân viên đã làm:';

    SELECT 
        PC.MA_NVIEN AS [Mã NV],
        COUNT(PC.MADA) AS [Số lượng đề án]
    FROM PHANCONG PC
    GROUP BY PC.MA_NVIEN;
END;

INSERT INTO DEAN (MADA, TENDA, DDIEM_DA, PHONG)
VALUES (99, N'Trigger Test', N'Hà Nội', 1);
DELETE FROM DEAN WHERE MADA = 99;

--Bài 3:
GO
Create or ALTER TRIGGER trg_XoaNhanVien_Thannhan
ON NHANVIEN
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1️ Xóa phân công liên quan trước
    DELETE FROM PHANCONG
    WHERE MA_NVIEN IN (SELECT MANV FROM DELETED);

    -- 2️ Xóa thân nhân liên quan
    DELETE FROM THANNHAN
    WHERE MA_NVIEN IN (SELECT MANV FROM DELETED);

    -- 3️ Cuối cùng xóa nhân viên
    DELETE FROM NHANVIEN
    WHERE MANV IN (SELECT MANV FROM DELETED);

    PRINT N' Đã xóa nhân viên, các thân nhân và các phân công liên quan.';
END;
GO

DELETE FROM NHANVIEN WHERE MANV = '001';

GO
CREATE OR ALTER TRIGGER trg_ThemNhanVien_PhanCong
ON NHANVIEN
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Thêm nhân viên mới
    INSERT INTO NHANVIEN (MANV, HONV, TENLOT, TENNV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
    SELECT MANV, HONV, TENLOT, TENNV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG
    FROM INSERTED;

    -- Chỉ thêm phân công nếu có công việc hợp lệ (MADA=1, STT=1)
    IF EXISTS (SELECT 1 FROM CONGVIEC WHERE MADA = 1 AND STT = 1)
    BEGIN
        INSERT INTO PHANCONG (MA_NVIEN, MADA, STT, THOIGIAN)
        SELECT 
            MANV,
            1 AS MADA,
            1 AS STT,
            0.5 AS THOIGIAN
        FROM INSERTED;

        PRINT N' Đã thêm nhân viên và tự động phân công vào đề án MADA=1, STT=1.';
    END
    ELSE
    BEGIN
        PRINT N' Không thể phân công vì không tồn tại công việc MADA=1, STT=1 trong CONGVIEC.';
    END
END;
GO


INSERT INTO NHANVIEN (MANV, HONV, TENLOT, TENNV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
VALUES ('999', N'Lê', N'Văn', N'Hủ', '1990-01-01', N'Hà Nội', N'Nam', 20000, '005', 1);












