--- Toàn bộ Store Procedure làm đồ án---

----/////////////////HOCVIEN//////////////////-----
drop procedure sp_ThemHocVien
Create proc sp_ThemHocVien
	@HoTen nvarchar(50), @CMND nvarchar(50), @DienThoai nvarchar(50), @NgaySinh datetime, @DiaChi nvarchar(50), @IDHocVien int out	
as
Begin
	/*Thêm 1 dòng dữ liệu vào HOCVIEN*/
	Insert Into HocVien (HoTen, CMND, DienThoai, NgaySinh, DiaChi)
	Values (@HoTen, @CMND, @DienThoai, @NgaySinh, @DiaChi )
	
	/*Lấy ID HOCVIEN*/
	select @IDHocVien = ID from HocVien where CMND = @CMND

End

declare @id int
exec sp_ThemHocVien N'Hồ Hải Nam','186853169','0909123789','01/01/1989','HCM',@id output
print N'Thêm học viên thành công!'
print @id

----/////////////////////////////////////// DANGKY //////////////////////////////////////////////----
Create Procedure sp_DangKy
	@IDMonThi int, @IDCaThi int, @IDHocVien int, @KetQua tinyint out
As
Begin
	
	/*Kiểm tra ca thi đó còn có thể đăng ký không*/
	-- Tính số lượng học viên đã đăng ký vào ca đó
	Declare @SoLuongDK int
	Select @SoLuongDK = Count(*)
	From DangKy DK
	Where DK.IDCaThi = @IDCaThi AND DK.IDMonThi = @IDMonThi
	
	-- Lấy số lượng học viên cho phép / ca
	Declare @SoLuongLIMIT int
	Select @SoLuongLIMIT = CT.SoLuong
	From CaThi CT
	Where CT.ID = @IDCaThi
	
	If (@SoLuongDK >= @SoLuongLIMIT)
	Begin
		Set @KetQua = 0
	End
	Else
		Begin
			/*Thêm 1 dòng dữ liệu vào DANGKY*/
			Insert Into DangKy (IDHocVien, IDCaThi, IDMonThi, NgayDat)
			Values (@IDHocVien, @IDCaThi, @IDMonThi, Cast(GetDate() As Date));
			Set @KetQua = 1
		End
	print N'Kết quả đăng ký: ' + Cast(@KetQua as nvarchar(50))
End




---SP test and fix HQTCSDL

---////////////////////////////////DOC DU LIEU RAC//////////////////////////////////////////////////////////----
---////////////////////////////////DOC DU LIEU RAC//////////////////////////////////////////////////////////----
---TEST TRUONG HOP READ UNCOMMITED - DOC DU LIEU RAC
drop procedure sp_ThemHocVien_rollback
Create proc sp_ThemHocVien_rollback
	@HoTen nvarchar(50), @CMND nvarchar(50), @DienThoai nvarchar(50), @DiaChi nvarchar(50), @IDHocVien int out	
as
Begin
	begin tran
		declare @dem int
		select @dem = COUNT(*) from HocVien where CMND = @CMND
		if @dem = 1
		begin
			set @IDHocVien = -2
			print N'cmnd đã tồn tại rồi'
			commit tran
			return			
		end
		/*Thêm 1 dòng dữ liệu vào HocVien*/
		Insert Into HocVien (HoTen, CMND, DienThoai,NgaySinh,DiaChi)
		Values (@HoTen, @CMND, @DienThoai,'01/01/1970', @DiaChi )
		waitfor delay '00:00:10'
		/* Kiểm tra xem tên có bị bỏ trống không,nếu có thì rollback */
		if(@HoTen = '' or @CMND = '' or @DienThoai = '' or @DiaChi = '')
			begin
				rollback
				set @IDHocVien = -1
				print N'không được để trống các trường cần thiết'
			end
		else
			begin
				select @IDHocVien = ID from HocVien where CMND = @CMND
				print N'thêm thông tin học viên thành công!'				
			end	
	commit tran

End

/*TEST*/
declare @id int
exec sp_ThemHocVien_rollback 'namhh','186853169','0964252945','','',@id


---TEST TRUONG HOP READ UNCOMMITED - DOC DU LIEU RAC O BANG HOC VIEN
drop proc sp_dsHocVien1

create proc sp_dsHocVien1
as 
begin
	begin tran
	set transaction isolation level read uncommitted
	select * from HocVien
	commit
end
/* FIX LOI */
create proc sp_dsHocVien2
as 
begin
	begin tran
	set transaction isolation level read committed
	select * from HocVien
	commit 
end
/*TEST*/
exec sp_dsHocVien2

/* Mô tả các tình huống tranh chấp */
T1:
declare @id int
exec sp_ThemHocVien_rollback 'namhh','186853169','0964252945','','',@id

T2:
exec sp_dsHocVien1
exec sp_dsHocVien2



---//////////////////////////////// PHAN TOM - HOCVIEN //////////////////////////////////////////////////////////----
---//////////////////////////////// PHAN TOM - HOCVIEN //////////////////////////////////////////////////////////----
drop procedure sp_ThemHocVien_phantom
Create proc sp_ThemHocVien_phantom
	@HoTen nvarchar(50), @CMND nvarchar(50), @DienThoai nvarchar(50), @DiaChi nvarchar(50), @IDHocVien int out	
as
Begin
	begin tran
		declare @dem int
		select @dem = COUNT(*) from HocVien where CMND = @CMND
		if @dem = 1
		begin
			set @IDHocVien = -2
			print N'cmnd đã tồn tại rồi'
			commit tran
			return			
		end
		/*Thêm 1 dòng dữ liệu vào HocVien*/
		Insert Into HocVien (HoTen, CMND, DienThoai, NgaySinh, DiaChi)
		Values (@HoTen, @CMND, @DienThoai,'01/01/1970', @DiaChi )
		/* Kiểm tra xem tên có bị bỏ trống không,nếu có thì rollback */
		if(@HoTen = '' or @CMND = '' or @DienThoai = '' or @DiaChi = '')
			begin
				rollback
				set @IDHocVien = -1
				print N'không được để trống các trường cần thiết'
			end
		else
			begin
				select @IDHocVien = ID from HocVien where CMND = @CMND
				print N'thêm thông tin học viên thành công!'				
			end	
	commit tran

End

/*TEST*/
declare @id int
exec sp_ThemHocVien_phantom 'namhh','186853169','0964252945','1/1/1989','HCM',@id


--- doc danh sach khach hang phantom
create procedure sp_docDanhSach_phantom
	@soluong1 int out,@soluong2 int out
as
begin
	begin transaction
		select @soluong1 = COUNT(*) from HocVien
		print N'SL 1 : ' + Cast(@soluong1 as nvarchar(50))
		waitfor delay '00:00:10'
		select @soluong2 = COUNT(*) from HocVien
		print N'SL 2 : ' + Cast(@soluong2 as nvarchar(50))
	commit transaction
end

create procedure sp_docDanhSach_phantom_fix
	@soluong1 int out,@soluong2 int out
as
begin
	begin transaction
		set transaction isolation level Serializable
		select @soluong1 = COUNT(*) from HocVien
		waitfor delay '00:00:10'
		select @soluong2 = COUNT(*) from HocVien
	commit transaction
end

/* Mô tả các tình huống tranh chấp */
T1:
declare @soluong1 int
declare @soluong2 int
exec sp_docDanhSach_phantom soluong1,soluong2
exec sp_docDanhSach_phantom_fix soluong1,soluong2

T2:
declare @id int
exec sp_ThemHocVien_phantom 'hnam','186853170','0964252945','1/1/1989','HCM',@id




---//////////////////////////////// KHONG DOC LAI DUOC DU LIEU //////////////////////////////////////////////////////////----
---//////////////////////////////// KHONG DOC LAI DUOC DU LIEU //////////////////////////////////////////////////////////----
--sp doc thong tin cua hoc vien
drop proc sp_thongtinHocVien_uread

create procedure sp_thongtinHocVien_uread
		@mahv int,@ten nvarchar(50)out,@cmnd nvarchar(50) out,@sodt nvarchar(50) out,@diachi nvarchar(50) out,@ten1 nvarchar(50)out,@cmnd1 nvarchar(50) out,@sodt1 nvarchar(50) out,@diachi1 nvarchar(50) out
	as
	begin
		begin tran
			select @ten = HoTen,@diachi = DiaChi,@sodt = DienThoai,@cmnd = CMND from HocVien where ID = @mahv
			print 'Ten la: '+ @ten
			waitfor delay '00:00:10'
			select @ten1 = HoTen,@diachi1 = DiaChi,@sodt1 = DienThoai,@cmnd1 = CMND from HocVien where ID = @mahv
			print 'Ten la: '+ @ten1
		commit tran --/ end transaction
	end --end procedure
--fix
create procedure sp_thongtinHocVien_uread_fix
		@mahv int,@ten nvarchar(50)out,@cmnd nvarchar(50) out,@sodt nvarchar(50) out,@diachi nvarchar(50) out,@ten1 nvarchar(50)out,@cmnd1 nvarchar(50) out,@sodt1 nvarchar(50) out,@diachi1 nvarchar(50) out
	as
	begin
		begin tran
			SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
			select @ten = HoTen,@diachi = DiaChi,@sodt = DienThoai,@cmnd = CMND from HocVien where ID = @mahv
			print 'Ten la: '+@ten
			waitfor delay '00:00:10'
			select @ten1 = HoTen,@diachi1 = DiaChi,@sodt1 = DienThoai,@cmnd1 = CMND from HocVien where ID = @mahv
			print 'Ten la: '+ @ten1
		commit tran --/ end transaction
	end --end procedure
	
	
--sp update thong tin hocvien
create procedure sp_UpdateHV_uread
	@IDHocVien int, @HoTen nvarchar(50), @CMND nvarchar(50), @DienThoai nvarchar(50), @DiaChi nvarchar(50)
as
begin
	begin transaction
		update HocVien set HoTen = @HoTen, CMND = @CMND, DienThoai = @DienThoai, NgaySinh = '01/01/1970', DiaChi = @DiaChi where ID = @IDHocVien
	commit transaction
end	

create procedure sp_UpdateHV_uread_fix
	@IDHocVien int, @HoTen nvarchar(50), @CMND nvarchar(50), @DienThoai nvarchar(50), @DiaChi nvarchar(50)
as
begin
	begin transaction
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
		update HocVien set HoTen = @HoTen, CMND = @CMND, DienThoai = @DienThoai, NgaySinh = '01/01/1970', DiaChi = @DiaChi where ID = @IDHocVien
	commit transaction
end
	

	
/* Mô tả các tình huống tranh chấp */
T1:	
declare @ten nvarchar(50)
declare @cmnd nvarchar(50)
declare @sodt nvarchar(50)	
declare @ngaysinh datetime
declare @diachi nvarchar(50)

declare @ten1 nvarchar(50)
declare @cmnd1 nvarchar(50)
declare @sodt1 nvarchar(50)	
declare @ngaysinh1 datetime
declare @diachi1 nvarchar(50)

exec sp_thongtinHocVien_uread 22,ten,cmnd,sodt,ngaysinh,diachi,ten1,cmnd1,sodt1,ngaysinh1,diachi1

T2:
exec sp_UpdateHV 22,'hnam','186853169','0909123789','01/01/1989','HCM'
