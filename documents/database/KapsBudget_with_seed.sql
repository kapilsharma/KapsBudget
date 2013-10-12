SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';


-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `users` ;

CREATE  TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `username` VARCHAR(50) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NOT NULL ,
  `password` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NOT NULL ,
  `email` VARCHAR(100) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NOT NULL ,
  `activated` TINYINT(1) NOT NULL DEFAULT 0 ,
  `activation_code` VARCHAR(10) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `username_UNIQUE` (`username` ASC) ,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `profiles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `profiles` ;

CREATE  TABLE IF NOT EXISTS `profiles` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `user_id` INT(11) NOT NULL ,
  `first_name` VARCHAR(30) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NOT NULL ,
  `last_name` VARCHAR(30) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_user_profiles_users_idx` (`user_id` ASC) ,
  CONSTRAINT `fk_user_profiles_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `category` ;

CREATE  TABLE IF NOT EXISTS `category` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `category_name` VARCHAR(45) NOT NULL ,
  `user_id` INT(11) NOT NULL COMMENT 'Use admin userid for default categories.' ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_category_users_idx` (`user_id` ASC) ,
  CONSTRAINT `fk_category_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `subcategory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `subcategory` ;

CREATE  TABLE IF NOT EXISTS `subcategory` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `category_id` INT(11) NOT NULL ,
  `subcategory_name` VARCHAR(45) NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_subcategory_category_idx` (`category_id` ASC) ,
  CONSTRAINT `fk_subcategory_category`
    FOREIGN KEY (`category_id` )
    REFERENCES `category` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `account_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `account_type` ;

CREATE  TABLE IF NOT EXISTS `account_type` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `type` VARCHAR(15) NOT NULL ,
  `description` TEXT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `account`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `account` ;

CREATE  TABLE IF NOT EXISTS `account` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `account_name` VARCHAR(45) NOT NULL ,
  `account_type_id` INT(11) NOT NULL ,
  `user_id` INT(11) NOT NULL ,
  `opening_balance` INT(11) NOT NULL DEFAULT 0 ,
  `current_balance` INT(11) NOT NULL DEFAULT 0 ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_account_account_type_idx` (`account_type_id` ASC) ,
  INDEX `fk_account_users_idx` (`user_id` ASC) ,
  CONSTRAINT `fk_account_account_type`
    FOREIGN KEY (`account_type_id` )
    REFERENCES `account_type` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_account_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `transaction_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `transaction_type` ;

CREATE  TABLE IF NOT EXISTS `transaction_type` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `transaction_type` VARCHAR(15) NOT NULL ,
  `description` TEXT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `register`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `register` ;

CREATE  TABLE IF NOT EXISTS `register` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `quickinfo` VARCHAR(50) NOT NULL ,
  `details` VARCHAR(300) NULL DEFAULT NULL ,
  `user_id` INT(11) NOT NULL ,
  `category_id` INT(11) NULL DEFAULT NULL COMMENT 'Required for transaction and Child. Null for other' ,
  `account_from` INT(11) NULL DEFAULT NULL COMMENT 'Required for transaction, Transfer and Parent. Null for Income and child' ,
  `account_to` INT(11) NULL DEFAULT NULL COMMENT 'Required for income and transfer. Null for other.' ,
  `transaction_type_id` INT(11) NOT NULL ,
  `parent_id` INT(11) NULL DEFAULT NULL COMMENT 'In case of transaction split, child will have parent id. Null otherwise' ,
  `total_child` SMALLINT NOT NULL DEFAULT 0 COMMENT 'In case of transaction split, parent need to remember total number of childs. ' ,
  `created_at` DATETIME NOT NULL ,
  `transaction_datetime` DATETIME NOT NULL COMMENT 'By default, transaction time will be the time when it added to the system. However if user forget to made some transaction of previous date, he can do so by setting transaction datetime manually.' ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_register_users_idx` (`user_id` ASC) ,
  INDEX `fk_register_category_idx` (`category_id` ASC) ,
  INDEX `fk_register_account_from_idx` (`account_from` ASC) ,
  INDEX `fk_register_account_to_idx` (`account_to` ASC) ,
  INDEX `fk_register_transaction_type_idx` (`transaction_type_id` ASC) ,
  INDEX `ind_trx_datetime` (`transaction_datetime` ASC) ,
  CONSTRAINT `fk_register_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_register_category`
    FOREIGN KEY (`category_id` )
    REFERENCES `subcategory` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_register_account_from`
    FOREIGN KEY (`account_from` )
    REFERENCES `account` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_register_account_to`
    FOREIGN KEY (`account_to` )
    REFERENCES `account` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_register_transaction_type`
    FOREIGN KEY (`transaction_type_id` )
    REFERENCES `transaction_type` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `account_type`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `account_type` (`id`, `type`, `description`) VALUES (NULL, 'Saving', 'Bank saving account');
INSERT INTO `account_type` (`id`, `type`, `description`) VALUES (NULL, 'Current', 'Bank current account');
INSERT INTO `account_type` (`id`, `type`, `description`) VALUES (NULL, 'FD', 'Bank fixed deposit');
INSERT INTO `account_type` (`id`, `type`, `description`) VALUES (NULL, 'Cash', 'Cash account like wallet, piggy bank etc');
INSERT INTO `account_type` (`id`, `type`, `description`) VALUES (NULL, 'Credit Card', 'Credit Card account');
INSERT INTO `account_type` (`id`, `type`, `description`) VALUES (NULL, 'Blackhole', 'Accounts where you intend to long term saving. Account where you will deposit amount but rarely or never withdraw. Examples are child account, PF account, retirement account etc.');
INSERT INTO `account_type` (`id`, `type`, `description`) VALUES (NULL, 'Wish', 'Similar to blackhole but have a fixed target. Do you wish to buy new car? How much you need to save? 10000. Create a wish account with goal as 1000.');

COMMIT;

-- -----------------------------------------------------
-- Data for table `transaction_type`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `transaction_type` (`id`, `transaction_type`, `description`) VALUES (NULL, 'Income', 'Add money to account');
INSERT INTO `transaction_type` (`id`, `transaction_type`, `description`) VALUES (NULL, 'Transaction', 'Withdraw money from account');
INSERT INTO `transaction_type` (`id`, `transaction_type`, `description`) VALUES (NULL, 'Transfer', 'Move money from one account to other');
INSERT INTO `transaction_type` (`id`, `transaction_type`, `description`) VALUES (NULL, 'Parent', 'Done shopping? You have unified bill (transaction - paying account) but individual items correspond to different category. Dont worry, just break a parent (transaction) defining paying account into child (transactions) defining categories.');
INSERT INTO `transaction_type` (`id`, `transaction_type`, `description`) VALUES (NULL, 'Child', 'Child to support parent.');

COMMIT;