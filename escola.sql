create database escola
go
use escola
go

create table ALUNO(
	ra int not null,
	nome varchar(50),
	constraint PK_ra primary key (ra)
);
go

create table DISCIPLINA(
	id_disciplina int not null identity(1,1),
	nome varchar(50),
	carga_horaria int not null,
	constraint PK_id_disciplina primary key(id_disciplina)
);
go
create table SEMESTRE(
	id_semestre int not null identity(1,1),
	descricao varchar(15) not null,
	ano int not null,
	constraint id_semestre primary key(id_semestre),
	constraint UniqueSemestre unique (descricao, ano)
)
​
create table CURSA(
	id_semestre int not null,
	id_disciplina int not null,
	ra int not null,
	frequencia float,
	situacao varchar(30) not null default 'REPROVADO',
	b1 float default 0,
	b2 float default 0,
	substitutiva float default 0,
	media float,
	falta int not null default 0,
	CONSTRAINT PK_SEM_DISC_RA primary key (id_semestre, id_disciplina, ra),
	constraint FK_id_disciplina foreign key(id_disciplina) references DISCIPLINA(id_disciplina),
	constraint FK_ra foreign key(ra) references ALUNO(ra),
	constraint FK_id_semestre foreign key(id_semestre) references SEMESTRE(id_semestre)
);

go

CREATE TRIGGER TCadastro_Cursa
ON CURSA
FOR INSERT
AS
Begin
	DECLARE
	@B1 FLOAT,
	@B2 FLOAT,
	@SUBSTITUTIVA FLOAT,
	@FREQUENCIA FLOAT,
	@MEDIA FLOAT,
	@FALTA FLOAT,
	@CARGA_HORARIA FLOAT,
	@SITUACAO VARCHAR(30),
	@ID_DISCIPLINA INT,
	@RA INT,
	@ID_SEMESTRE INT
​
	SELECT @RA = ra, @FALTA = falta, @B1 = b1, @B2 = b2, @SUBSTITUTIVA = substitutiva, @ID_DISCIPLINA = id_disciplina, @ID_SEMESTRE = id_semestre
	FROM INSERTED
​
	SELECT @CARGA_HORARIA = d.carga_horaria 
	from DISCIPLINA D WHERE D.id_disciplina = @ID_DISCIPLINA
​
	UPDATE CURSA SET 
	CURSA.frequencia =  100 - ((@FALTA/@CARGA_HORARIA)*100),
	CURSA.media = CASE WHEN (@B1 + @B2)/2 < 6 THEN 
	CASE WHEN @B2>@B1 THEN (@SUBSTITUTIVA + @B2)/2
	ELSE (@SUBSTITUTIVA + @B1)/2 END
	ELSE (@B1 + @B2) / 2 END
	WHERE CURSA.ra = @RA AND CURSA.id_disciplina = @ID_DISCIPLINA AND CURSA.id_semestre  = @ID_SEMESTRE
​
	UPDATE CURSA SET 
	CURSA.situacao = CASE WHEN cursa.frequencia < 75 THEN 'REPROVADO POR FALTA' 
	WHEN CURSA.media < 6 THEN 'REPROVADO POR NOTA'
	ELSE 'APROVADO' END
	WHERE CURSA.ra = @RA AND CURSA.id_disciplina = @ID_DISCIPLINA AND CURSA.id_semestre  = @ID_SEMESTRE
END
GO

insert into ALUNO values(50137022, 'Leonardo')
insert into ALUNO values(50137098, 'Irwing')
insert into ALUNO values(50137090, 'Jonson')
insert into ALUNO values(50137093, 'Maria')
select * from ALUNO

insert into DISCIPLINA values ('Estrutura de Dados', 30)
insert into DISCIPLINA values ('Banco de Dados', 20)
select * from DISCIPLINA

​
insert into SEMESTRE values('semestre 1', 2019)
insert into SEMESTRE values('semestre 2', 2019)
insert into SEMESTRE values('semestre 1', 2020)
insert into SEMESTRE values('semestre 2', 2020)
insert into SEMESTRE values('semestre 1', 2021)
select * from SEMESTRE order by id_semestre


insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(1, 1, 50137022, 2, 2, 2, 2)

insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(4, 2, 50137022, 6, 4, 9, 5)

insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(3, 2, 50137022, 2, 2, 2, 5)

insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(1, 1, 50137098, 8, 8, 2,10)
​
insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(1, 1, 50137010, 8, 8, 0,2)
​
insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(3, 2, 50137022, 10, 8, 2, 2)
​
insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(2, 1, 50137022, 8, 5, 2, 10)

insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(1, 1, 50137090, 8, 6, 2, 0)

insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(1, 2, 50137090, 8, 6, 2, 0)

insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(2, 1, 50137090, 8, 6, 2, 0)

insert into CURSA (id_semestre, id_disciplina, ra, b1, b2, substitutiva, falta)
VALUES(2, 2, 50137090, 8, 6, 2, 0)

SELECT * FROM CURSA

-- (A) ALUNOS DE UMA DETERMINADA DISCIPLINA NO ANO DE 2020
SELECT A.nome, D.nome, S.descricao, C.b1, C.b2, C.substitutiva, C.media
FROM ALUNO A
JOIN CURSA C ON C.ra = A.ra
JOIN DISCIPLINA D ON D.id_disciplina = C.id_disciplina
JOIN SEMESTRE S ON S.id_semestre = C.id_semestre
WHERE S.ano = 2020 AND D.nome = 'Banco de Dados'

-- (B) NOTAS DO ALUNO DO SEGUNDO SEMESTRE DE 2019
SELECT A.nome, D.nome, C.b1, C.b2, C.substitutiva, C.media
FROM CURSA C 
JOIN ALUNO A ON A.ra = C.ra
JOIN DISCIPLINA D ON D.id_disciplina = C.id_disciplina
JOIN SEMESTRE S ON S.id_semestre = C.id_semestre
WHERE S.ano = 2019 AND S.descricao = 'semestre 2' AND  A.nome = 'Leonardo' 

-- (C) ALUNOS REPROVADOS POR NOTA EM 2020 POR CURSO
SELECT A.nome, D.nome, S.descricao, C.media, C.situacao
FROM ALUNO A
JOIN CURSA C ON C.ra = A.ra
JOIN DISCIPLINA D ON D.id_disciplina = C.id_disciplina
JOIN SEMESTRE S ON S.id_semestre = C.id_semestre
WHERE C.media < 6 AND C.situacao = 'REPROVADO POR NOTA' AND S.ano = 2020 AND D.nome = 'Banco de Dados'

-- (D) HISTORICO DE APROVADOS DA ESCOLA
SELECT A.nome, D.nome, S.ano, S.descricao, C.frequencia, C.media, C.situacao
FROM ALUNO A
JOIN CURSA C ON C.ra = A.ra
JOIN DISCIPLINA D ON D.id_disciplina = C.id_disciplina
JOIN SEMESTRE S ON S.id_semestre = C.id_semestre
WHERE C.media > 6 AND C.frequencia >= 75