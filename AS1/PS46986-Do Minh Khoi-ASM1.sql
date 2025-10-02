CREATE DATABASE QLNHATRO_DoMinhKhoi;
GO
USE QLNHATRO_DoMinhKhoi;
GO
CREATE TABLE LOAINHA (
    MaLoaiNha INT IDENTITY(1,1) PRIMARY KEY,
    TenLoaiNha NVARCHAR(100) NOT NULL UNIQUE
);
GO
CREATE TABLE NGUOIDUNG (
    MaNguoiDung INT IDENTITY(1,1) PRIMARY KEY,
    TenNguoiDung NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    DienThoai VARCHAR(15) NOT NULL UNIQUE,
    SoNha NVARCHAR(50),
    TenDuong NVARCHAR(100),
    TenPhuong NVARCHAR(100),
    Quan NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);
GO
CREATE TABLE NHATRO (
    MaNhaTro INT IDENTITY(1,1) PRIMARY KEY,
    MaLoaiNha INT NOT NULL FOREIGN KEY REFERENCES LOAINHA(MaLoaiNha),
    DienTich DECIMAL(5,2) NOT NULL CHECK (DienTich > 0),
    GiaPhong DECIMAL(12,2) NOT NULL CHECK (GiaPhong > 0),
    SoNha NVARCHAR(50),
    TenDuong NVARCHAR(100),
    TenPhuong NVARCHAR(100),
    Quan NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(MAX),
    NgayDang DATE NOT NULL DEFAULT GETDATE(),
    MaNguoiDung INT NOT NULL FOREIGN KEY REFERENCES NGUOIDUNG(MaNguoiDung)
);
GO
INSERT INTO LOAINHA (TenLoaiNha) VALUES
(N'Căn hộ chung cư'),
(N'Nhà riêng'),
(N'Phòng trọ khép kín');
GO
INSERT INTO NGUOIDUNG (TenNguoiDung, GioiTinh, DienThoai, SoNha, TenDuong, TenPhuong, Quan, Email) VALUES
(N'Nguyễn Văn A', N'Nam', '0918000001', '12', N'Nguyễn Thị Minh Khai', N'Bến Nghé', N'Quận 1', 'vana@hcm.com'),
(N'Trần Thị B', N'Nữ', '0918000002', '45', N'Điện Biên Phủ', N'Đa Kao', N'Quận 1', 'thib@hcm.com'),
(N'Lê Văn C', N'Nam', '0918000003', '89', N'Cách Mạng Tháng 8', N'15', N'Quận 10', 'vanc@hcm.com'),
(N'Phạm Thị D', N'Nữ', '0918000004', '56', N'Lê Văn Sỹ', N'13', N'Quận 3', 'thid@hcm.com'),
(N'Hoàng Văn E', N'Nam', '0918000005', '23', N'Nguyễn Văn Cừ', N'Nguyễn Cư Trinh', N'Quận 5', 'vane@hcm.com'),
(N'Đỗ Thị F', N'Nữ', '0918000006', '101', N'Phạm Văn Đồng', N'Hiệp Bình Chánh', N'Thủ Đức', 'thif@hcm.com'),
(N'Ngô Văn G', N'Nam', '0918000007', '77', N'Kha Vạn Cân', N'Linh Trung', N'Thủ Đức', 'vang@hcm.com'),
(N'Vũ Thị H', N'Nữ', '0918000008', '34', N'Quang Trung', N'14', N'Gò Vấp', 'thih@hcm.com'),
(N'Bùi Văn I', N'Nam', '0918000009', '66', N'Âu Cơ', N'9', N'Tân Bình', 'vani@hcm.com'),
(N'Cao Thị K', N'Nữ', '0918000010', '200', N'Hòa Bình', N'5', N'Tân Phú', 'thik@hcm.com');
GO
INSERT INTO NHATRO (MaLoaiNha, DienTich, GiaPhong, SoNha, TenDuong, TenPhuong, Quan, MoTa, MaNguoiDung)
VALUES
(1, 25.5, 3500000, '12', N'Nguyễn Thị Minh Khai', N'Bến Nghé', N'Quận 1', N'Căn hộ mini, trung tâm quận 1', 1),
(2, 45.0, 5000000, '45', N'Điện Biên Phủ', N'Đa Kao', N'Quận 1', N'Nhà riêng 2 tầng, gần công viên Lê Văn Tám', 2),
(3, 18.0, 2500000, '89', N'Cách Mạng Tháng 8', N'15', N'Quận 10', N'Phòng trọ nhỏ, gần Đại học Bách Khoa', 3),
(1, 30.0, 4000000, '56', N'Lê Văn Sỹ', N'13', N'Quận 3', N'Căn hộ mini, nội thất cơ bản', 4),
(2, 60.0, 6000000, '23', N'Nguyễn Văn Cừ', N'Nguyễn Cư Trinh', N'Quận 5', N'Nhà nguyên căn, phù hợp gia đình', 5),
(3, 20.0, 2800000, '101', N'Phạm Văn Đồng', N'Hiệp Bình Chánh', N'Thủ Đức', N'Phòng trọ mới xây, an ninh tốt', 6),
(1, 40.0, 4500000, '77', N'Kha Vạn Cân', N'Linh Trung', N'Thủ Đức', N'Căn hộ mini, gần Đại học Quốc Gia', 7),
(2, 55.0, 5500000, '34', N'Quang Trung', N'14', N'Gò Vấp', N'Nhà nguyên căn, khu vực yên tĩnh', 8),
(3, 22.0, 3000000, '66', N'Âu Cơ', N'9', N'Tân Bình', N'Phòng trọ giá rẻ, gần chợ Tân Bình', 9),
(1, 35.0, 4200000, '200', N'Hòa Bình', N'5', N'Tân Phú', N'Căn hộ chung cư mini, gần Aeon Mall Tân Phú', 10);
GO
INSERT INTO DANHGIA (MaNguoiDung, MaNhaTro, TrangThai, NoiDung)
VALUES
(1, 1, 'LIKE', N'Phòng đẹp, sạch sẽ, gần trường'),
(2, 1, 'DISLIKE', N'Giá hơi cao so với sinh viên'),
(3, 2, 'LIKE', N'Nhà riêng yên tĩnh, phù hợp gia đình nhỏ'),
(4, 3, 'LIKE', N'Phòng rẻ, phù hợp sinh viên'),
(5, 4, 'DISLIKE', N'Phòng hơi chật, không có cửa sổ'),
(6, 5, 'LIKE', N'Nhà rộng rãi, thoáng mát'),
(7, 6, 'DISLIKE', N'Phòng trọ ồn ào, gần đường lớn'),
(8, 7, 'LIKE', N'Gần bến xe bus, đi lại thuận tiện'),
(9, 8, 'LIKE', N'Chủ nhà dễ tính, an ninh tốt'),
(10, 9, 'LIKE', N'Phòng đẹp, gần trường đại học');
GO
