-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 16-Jan-2022 às 22:51
-- Versão do servidor: 10.4.22-MariaDB
-- versão do PHP: 8.1.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `controlefinancas`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `conta`
--

CREATE TABLE `conta` (
  `idconta` int(11) NOT NULL,
  `tipoConta` enum('carteira','contaCorrente','contaPoupanca','instituicaoFinaceira') DEFAULT NULL,
  `saldo` double(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `conta`
--

INSERT INTO `conta` (`idconta`, `tipoConta`, `saldo`) VALUES
(1, 'contaCorrente', 2850.51);

-- --------------------------------------------------------

--
-- Estrutura da tabela `despesa`
--

CREATE TABLE `despesa` (
  `iddespesa` int(11) NOT NULL,
  `valor` double(10,2) DEFAULT NULL,
  `dataPagamento` date DEFAULT NULL,
  `dataPagamentoEsperado` date DEFAULT NULL,
  `tipoDespesa` enum('alimentacao','educacao','lazer','moradia','roupa','saude','transporte','outros') DEFAULT NULL,
  `id_conta` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `despesa`
--

INSERT INTO `despesa` (`iddespesa`, `valor`, `dataPagamento`, `dataPagamentoEsperado`, `tipoDespesa`, `id_conta`) VALUES
(1, 550.99, '2022-01-16', '2022-01-16', 'alimentacao', 1);

--
-- Acionadores `despesa`
--
DELIMITER $$
CREATE TRIGGER `despesasaldo` AFTER INSERT ON `despesa` FOR EACH ROW Begin
	
	insert into saldo values(0,new.valor,new.id_conta);
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita`
--

CREATE TABLE `receita` (
  `idreceita` int(11) NOT NULL,
  `valor` double(10,2) DEFAULT NULL,
  `dataRecebimento` date DEFAULT NULL,
  `dataRecebimentoEsperado` date DEFAULT NULL,
  `descricao` varchar(300) DEFAULT NULL,
  `tipoReceita` enum('salario','presente','premio','outros') DEFAULT NULL,
  `id_conta` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `receita`
--

INSERT INTO `receita` (`idreceita`, `valor`, `dataRecebimento`, `dataRecebimentoEsperado`, `descricao`, `tipoReceita`, `id_conta`) VALUES
(2, 3401.50, '2022-01-16', '2022-01-16', 'salario bom', 'salario', 1);

--
-- Acionadores `receita`
--
DELIMITER $$
CREATE TRIGGER `adicionaSaldo` AFTER INSERT ON `receita` FOR EACH ROW BEGIN
	
	insert into saldo values(new.valor,0,new.id_conta); 
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `saldo`
--

CREATE TABLE `saldo` (
  `receitas` double DEFAULT NULL,
  `despesas` double DEFAULT NULL,
  `id_conta` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `saldo`
--

INSERT INTO `saldo` (`receitas`, `despesas`, `id_conta`) VALUES
(3401.5, 0, 1),
(0, 550.99, 1);

--
-- Acionadores `saldo`
--
DELIMITER $$
CREATE TRIGGER `saldoTotals` AFTER INSERT ON `saldo` FOR EACH ROW BEGIN
		DECLARE vtotal real;
		
		SET vtotal := new.receitas - new.despesas;
		
		
		UPDATE conta 
		SET saldo = saldo + vtotal
		WHERE idconta = new.id_conta;
		
		
		
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `transferencia`
--

CREATE TABLE `transferencia` (
  `valorconta1` double DEFAULT NULL,
  `id_conta` int(11) DEFAULT NULL,
  `id_conta1` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Acionadores `transferencia`
--
DELIMITER $$
CREATE TRIGGER `tranferencia` AFTER INSERT ON `transferencia` FOR EACH ROW BEGIN
	declare vtranf real;
	
	set vtranf := new.valorconta1;
	
	UPDATE conta 
	SET saldo = saldo - vtranf
	WHERE idconta = new.id_conta;
	
	UPDATE conta 
	SET saldo = saldo + vtranf
	WHERE idconta = new.id_conta1;
	
end
$$
DELIMITER ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `conta`
--
ALTER TABLE `conta`
  ADD PRIMARY KEY (`idconta`);

--
-- Índices para tabela `despesa`
--
ALTER TABLE `despesa`
  ADD PRIMARY KEY (`iddespesa`),
  ADD KEY `FK_despesa_conta` (`id_conta`);

--
-- Índices para tabela `receita`
--
ALTER TABLE `receita`
  ADD PRIMARY KEY (`idreceita`),
  ADD KEY `fk_receita_conta` (`id_conta`);

--
-- Índices para tabela `saldo`
--
ALTER TABLE `saldo`
  ADD KEY `fk_saldo_conta` (`id_conta`);

--
-- Índices para tabela `transferencia`
--
ALTER TABLE `transferencia`
  ADD KEY `fk_tranferencia_conta` (`id_conta`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `conta`
--
ALTER TABLE `conta`
  MODIFY `idconta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `despesa`
--
ALTER TABLE `despesa`
  MODIFY `iddespesa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `receita`
--
ALTER TABLE `receita`
  MODIFY `idreceita` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `despesa`
--
ALTER TABLE `despesa`
  ADD CONSTRAINT `FK_despesa_conta` FOREIGN KEY (`id_conta`) REFERENCES `conta` (`idconta`);

--
-- Limitadores para a tabela `receita`
--
ALTER TABLE `receita`
  ADD CONSTRAINT `fk_receita_conta` FOREIGN KEY (`id_conta`) REFERENCES `conta` (`idconta`);

--
-- Limitadores para a tabela `saldo`
--
ALTER TABLE `saldo`
  ADD CONSTRAINT `fk_saldo_conta` FOREIGN KEY (`id_conta`) REFERENCES `conta` (`idconta`);

--
-- Limitadores para a tabela `transferencia`
--
ALTER TABLE `transferencia`
  ADD CONSTRAINT `fk_tranferencia_conta` FOREIGN KEY (`id_conta`) REFERENCES `conta` (`idconta`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
