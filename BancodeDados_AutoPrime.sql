CREATE TABLE cliente (
 	id_cliente 	SERIAL PRIMARY KEY,
 	nome       	VARCHAR(120) NOT NULL,
 	cpf        	CHAR(11) 	NOT NULL UNIQUE,
 	telefone   	VARCHAR(20),
 	email      	VARCHAR(120),
 	endereco   	VARCHAR(200),
 	data_cadastro  DATE NOT NULL DEFAULT CURRENT_DATE
 );

 CREATE TABLE funcionario (
 	id_funcionario SERIAL PRIMARY KEY,
 	nome       	VARCHAR(120) NOT NULL,
 	cpf        	CHAR(11) 	NOT NULL UNIQUE,
 	cargo      	VARCHAR(60)  NOT NULL,
 	setor      	VARCHAR(40)  NOT NULL,
 	data_admissao  DATE NOT NULL DEFAULT CURRENT_DATE
 );

 CREATE TABLE fornecedor (
 	id_fornecedor  SERIAL PRIMARY KEY,
 	razao_social   VARCHAR(120) NOT NULL,
 	cnpj       	CHAR(14) 	NOT NULL UNIQUE,
 	telefone   	VARCHAR(20),
 	email      	VARCHAR(120)
 );

 CREATE TABLE veiculo (
 	id_veiculo  	SERIAL PRIMARY KEY,
 	chassi      	CHAR(17)  	NOT NULL UNIQUE,
 	marca       	VARCHAR(40)   NOT NULL,
 	modelo      	VARCHAR(60)   NOT NULL,
 	ano_fabricacao  SMALLINT      NOT NULL,
 	ano_modelo  	SMALLINT  	NOT NULL,
 	cor         	VARCHAR(30),
 	quilometragem   INTEGER       NOT NULL DEFAULT 0 CHECK (quilometragem >= 0),
 	condicao    	VARCHAR(10)   NOT NULL CHECK (condicao IN ('NOVO', 'SEMINOVO')),
 	preco_venda 	NUMERIC(12,2) NOT NULL CHECK (preco_venda > 0),
 	situacao    	VARCHAR(12)   NOT NULL DEFAULT 'DISPONIVEL'
                 	CHECK (situacao IN ('DISPONIVEL', 'RESERVADO', 'VENDIDO')),
 	id_fornecedor   INTEGER,
 	CONSTRAINT fk_veiculo_fornecedor FOREIGN KEY (id_fornecedor)
     	REFERENCES fornecedor (id_fornecedor)
 );

 CREATE TABLE venda (
 	id_venda     	SERIAL PRIMARY KEY,
 	data_venda   	DATE      	NOT NULL DEFAULT CURRENT_DATE,
 	forma_pagamento  VARCHAR(20)   NOT NULL CHECK (forma_pagamento IN ('A_VISTA', 'FINANCIADO')),
 	valor_total  	NUMERIC(12,2) NOT NULL CHECK (valor_total > 0),
 	id_cliente   	INTEGER NOT NULL,
 	id_funcionario   INTEGER NOT NULL,
 	CONSTRAINT fk_venda_cliente FOREIGN KEY (id_cliente)
     	REFERENCES cliente (id_cliente),
 	CONSTRAINT fk_venda_funcionario FOREIGN KEY (id_funcionario)
     	REFERENCES funcionario (id_funcionario)
 );

 CREATE TABLE item_venda (
 	id_venda     	INTEGER NOT NULL,
 	id_veiculo   	INTEGER NOT NULL UNIQUE,
 	valor_negociado  NUMERIC(12,2) NOT NULL CHECK (valor_negociado > 0),
 	PRIMARY KEY (id_venda, id_veiculo),
 	CONSTRAINT fk_item_venda_venda FOREIGN KEY (id_venda)
     	REFERENCES venda (id_venda),
 	CONSTRAINT fk_item_venda_veiculo FOREIGN KEY (id_veiculo)
     	REFERENCES veiculo (id_veiculo)
 );

 CREATE TABLE financiamento (
 	id_financiamento	SERIAL PRIMARY KEY,
 	id_venda        	INTEGER NOT NULL UNIQUE,
 	instituicao     	VARCHAR(80)   NOT NULL,
 	valor_financiado	NUMERIC(12,2) NOT NULL CHECK (valor_financiado > 0),
 	num_parcelas    	SMALLINT  	NOT NULL CHECK (num_parcelas > 0),
 	taxa_juros_mensal   NUMERIC(5,2)  NOT NULL CHECK (taxa_juros_mensal >= 0),
 	data_contratacao	DATE NOT NULL DEFAULT CURRENT_DATE,
 	CONSTRAINT fk_financiamento_venda FOREIGN KEY (id_venda)
     	REFERENCES venda (id_venda)
 );

 CREATE TABLE pagamento (
 	id_pagamento 	SERIAL PRIMARY KEY,
 	id_venda     	INTEGER   	NOT NULL,
 	numero_parcela   SMALLINT      NOT NULL CHECK (numero_parcela > 0),
 	valor        	NUMERIC(12,2) NOT NULL CHECK (valor > 0),
 	data_vencimento  DATE          NOT NULL,
 	data_pagamento   DATE,
 	status       	VARCHAR(10)   NOT NULL DEFAULT 'PENDENTE'
                  	CHECK (status IN ('PENDENTE', 'PAGO', 'ATRASADO')),
 	UNIQUE (id_venda, numero_parcela),
 	CONSTRAINT fk_pagamento_venda FOREIGN KEY (id_venda)
     	REFERENCES venda (id_venda)
 );

 CREATE TABLE peca (
 	id_peca    	SERIAL PRIMARY KEY,
 	codigo     	VARCHAR(30)   NOT NULL UNIQUE,
 	descricao  	VARCHAR(150)  NOT NULL,
 	preco_venda	NUMERIC(10,2) NOT NULL CHECK (preco_venda >= 0),
 	id_fornecedor  INTEGER,
 	CONSTRAINT fk_peca_fornecedor FOREIGN KEY (id_fornecedor)
     	REFERENCES fornecedor (id_fornecedor)
 );

 CREATE TABLE estoque_peca (
 	id_peca     	INTEGER PRIMARY KEY,
 	quantidade  	INTEGER NOT NULL DEFAULT 0 CHECK (quantidade >= 0),
 	estoque_minimo  INTEGER NOT NULL DEFAULT 5 CHECK (estoque_minimo >= 0),
 	localizacao 	VARCHAR(30),
 	CONSTRAINT fk_estoque_peca FOREIGN KEY (id_peca)
     	REFERENCES peca (id_peca)
 );

 CREATE TABLE ordem_servico (
 	id_os           	SERIAL PRIMARY KEY,
 	data_abertura   	DATE NOT NULL DEFAULT CURRENT_DATE,
 	data_conclusao  	DATE,
 	status          	VARCHAR(15) NOT NULL DEFAULT 'ABERTA'
                     	CHECK (status IN ('ABERTA', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')),
 	placa           	VARCHAR(8)  NOT NULL,
 	modelo_veiculo  	VARCHAR(60) NOT NULL,
 	descricao_problema  VARCHAR(300),
 	id_cliente      	INTEGER NOT NULL,
 	id_funcionario  	INTEGER NOT NULL,
 	CHECK (data_conclusao IS NULL OR data_conclusao >= data_abertura),
 	CONSTRAINT fk_os_cliente FOREIGN KEY (id_cliente)
     	REFERENCES cliente (id_cliente),
 	CONSTRAINT fk_os_funcionario FOREIGN KEY (id_funcionario)
     	REFERENCES funcionario (id_funcionario)
 );

 CREATE TABLE item_os (
 	id_item_os     	SERIAL PRIMARY KEY,
 	id_os          	INTEGER   	NOT NULL,
 	id_peca        	INTEGER,
 	descricao_servico  VARCHAR(150),
 	quantidade     	INTEGER   	NOT NULL DEFAULT 1 CHECK (quantidade > 0),
 	valor_unitario 	NUMERIC(10,2) NOT NULL CHECK (valor_unitario >= 0),
 	CHECK (id_peca IS NOT NULL OR descricao_servico IS NOT NULL),
 	CONSTRAINT fk_item_os_os FOREIGN KEY (id_os)
     	REFERENCES ordem_servico (id_os),
 	CONSTRAINT fk_item_os_peca FOREIGN KEY (id_peca)
     	REFERENCES peca (id_peca)
 );
