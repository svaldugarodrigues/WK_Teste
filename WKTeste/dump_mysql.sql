CREATE DATABASE IF NOT EXISTS pedidos_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pedidos_db;

CREATE TABLE clientes (
  codigo INT NOT NULL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cidade VARCHAR(60),
  uf CHAR(2),
  INDEX idx_clientes_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE produtos (
  codigo INT NOT NULL PRIMARY KEY,
  descricao VARCHAR(150) NOT NULL,
  preco_venda DECIMAL(15,2) NOT NULL,
  INDEX idx_produtos_descricao (descricao)
) ENGINE=InnoDB;

CREATE TABLE pedidos (
  numero_pedido INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  data_emissao DATETIME NOT NULL,
  codigo_cliente INT NOT NULL,
  valor_total DECIMAL(15,2) NOT NULL,
  INDEX idx_pedidos_cliente (codigo_cliente),
  CONSTRAINT fk_pedidos_cliente FOREIGN KEY (codigo_cliente) REFERENCES clientes(codigo) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pedidos_produtos (
  codigo INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  numero_pedido INT NOT NULL,
  codigo_produto INT NOT NULL,
  quantidade DECIMAL(15,4) NOT NULL,
  valor_unitario DECIMAL(15,4) NOT NULL,
  valor_total DECIMAL(15,4) NOT NULL,
  INDEX idx_pp_numero (numero_pedido),
  INDEX idx_pp_produto (codigo_produto),
  CONSTRAINT fk_pp_pedido FOREIGN KEY (numero_pedido) REFERENCES pedidos(numero_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pp_produto FOREIGN KEY (codigo_produto) REFERENCES produtos(codigo) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

INSERT INTO clientes (codigo, nome, cidade, uf) VALUES
(1,'ACME Comercio Ltda','São Paulo','SP'),
(2,'Casa e Cia','Campinas','SP'),
(3,'Distribuidora Alfa','Rio de Janeiro','RJ'),
(4,'Loja Beta','Belo Horizonte','MG'),
(5,'Comercial Gama','Porto Alegre','RS'),
(6,'Mercado Delta','Salvador','BA'),
(7,'Super Nova','Curitiba','PR'),
(8,'Tech Solutions','Florianópolis','SC'),
(9,'Auto Peças Z','Fortaleza','CE'),
(10,'Móveis Silva','Recife','PE'),
(11,'EletroCasa','Goiânia','GO'),
(12,'Papelaria Central','Manaus','AM'),
(13,'Oficina do João','Natal','RN'),
(14,'Hortifruti Bom','Vitória','ES'),
(15,'Livraria Lumen','Maceió','AL'),
(16,'Farmácia Vida','Aracaju','SE'),
(17,'Roupas & Estilo','Cuiabá','MT'),
(18,'Brinquedos Kids','Campo Grande','MS'),
(19,'PetFeliz','São Luís','MA'),
(20,'Bazar Popular','João Pessoa','PB');

INSERT INTO produtos (codigo, descricao, preco_venda) VALUES
(1001,'Parafuso 5x20 (pacote)',2.50),
(1002,'Prego 3x35 (pacote)',1.80),
(1003,'Martelo 16oz',45.00),
(1004,'Chave Phillips 2mm',12.00),
(1005,'Alicate 8"',35.50),
(1006,'Fita Isolante 10m',4.75),
(1007,'Lâmpada LED 9W',18.90),
(1008,'Tomada 2P + Terra',9.50),
(1009,'Cabo USB 2m',15.00),
(1010,'Extensão 3 tomadas 5m',28.00),
(1011,'Tinta Látex 18L Branco',189.90),
(1012,'Rolo de pintura 23cm',22.40),
(1013,'Pincel 2"',6.30),
(1014,'Vedante Silicone 300ml',11.50),
(1015,'Serra Manual 22"',79.99),
(1016,'Furadeira 550W',299.00),
(1017,'Óleo Lubrificante 1L',24.50),
(1018,'Chave Inglesa 10"',49.90),
(1019,'Trena 5m',17.20),
(1020,'Lixa 120 (pacote 10)',3.60);

CREATE INDEX idx_pedidos_data_cliente ON pedidos (data_emissao, codigo_cliente);