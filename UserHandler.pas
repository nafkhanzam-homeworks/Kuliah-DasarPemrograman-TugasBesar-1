unit UserHandler;

interface
	uses
		Util, Database;
	var
		loggedUser: User;
	procedure login;
	procedure register;
	procedure cari_anggota;

implementation
	procedure login;
		var
			username, password: string;
			u: User;
		begin
			write('Masukkan username: ');
			readln(username);
			write('Masukkan password: ');
			readln(password);
			u := findUser(username);
			if isUserNull(u) or (u.password <> hashCode(password)) then
				writeln('Username / password salah! Silakan coba lagi.')
			else begin
				writeln('Selamat datang ', u.username, '!');
				loggedUser := u;
			end;
		end;
	procedure register;
		var 
			password: string;
			res: User;
		begin
			write('Masukkan nama pengunjung: ');
			readln(res.nama);
			write('Masukkan alamat pengunjung: ');
			readln(res.alamat);
			write('Masukkan username pengunjung: ');
			readln(res.username);
			write('Masukkan password pengunjung: ');
			readln(password);
			res.password := hashCode(password);
			res.role := ROLE_PENGUNJUNG;
			addUser(res);
			writeln('Pengunjung ', res.nama, ' berhasil terdaftar sebagai user.');
		end;
	procedure cari_anggota;
		var
			s: string;
			u: User;
		begin
			write('Masukkan username: ');
			readln(s);
			u := findUser(s);
			if isUserNull(u) then
				writeln('User tidak ditemukan.')
			else begin
				writeln('Nama Anggota: ', u.nama);
				writeln('Alamat anggota: ', u.alamat);
			end;
		end;

end.