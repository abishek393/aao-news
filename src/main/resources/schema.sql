-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS aaonews;
USE aaonews;

-- Role Definitions
CREATE TABLE IF NOT EXISTS roles
(
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
) COMMENT ='Defines user roles in the system';

-- User Status Table Definitions
-- 1: active, 2: deactivated, 3: pending, 4: suspended, 5: banned
CREATE TABLE IF NOT EXISTS user_statuses
(
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
) COMMENT ='Defines user status in the system';

-- Users table
CREATE TABLE IF NOT EXISTS users
(
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email          VARCHAR(255) NOT NULL UNIQUE,
    username       VARCHAR(50)  NOT NULL UNIQUE,
    password       VARCHAR(255) NOT NULL,
    full_name      VARCHAR(100) NOT NULL,
    role_id        INT UNSIGNED NOT NULL,
    phone_number   VARCHAR(15)  NULL UNIQUE,
    email_verified BOOLEAN      DEFAULT FALSE,
    user_status_id INT UNSIGNED DEFAULT 1,
    profile_image  MEDIUMBLOB, -- Storing image Binary data MAX-SIZE: 16MB
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login     TIMESTAMP    NULL,
    FOREIGN KEY (role_id) REFERENCES roles (id),
    FOREIGN KEY (user_status_id) REFERENCES user_statuses (id),
    INDEX idx_users_email (email),
    INDEX idx_users_username (username),
    INDEX idx_users_phone (phone_number),
    INDEX idx_users_status (user_status_id),
    INDEX idx_users_role (role_id)
) COMMENT ='Stores user account information';

-- Publisher information table
CREATE TABLE IF NOT EXISTS publisher_info
(
    publisher_id      INT UNSIGNED PRIMARY KEY,
    is_individual     BOOLEAN DEFAULT TRUE,
    is_verified       BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP NULL,
    FOREIGN KEY (publisher_id) REFERENCES users (id) ON DELETE CASCADE
) COMMENT ='Stores core info for all publishers';

-- Individual publisher information
CREATE TABLE IF NOT EXISTS individual_info
(
    publisher_id     INT UNSIGNED PRIMARY KEY,
    national_id_type VARCHAR(50) NOT NULL,
    national_id_no   VARCHAR(50) NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publisher_info (publisher_id) ON DELETE CASCADE
) COMMENT ='Stores identity verification for individual publishers';

-- Organization publisher information
CREATE TABLE IF NOT EXISTS organization_info
(
    publisher_id         INT UNSIGNED PRIMARY KEY,
    organization_name    VARCHAR(100) NOT NULL,
    organization_website VARCHAR(255),
    pan_number           VARCHAR(20)  NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publisher_info (publisher_id) ON DELETE CASCADE
) COMMENT ='Stores information for organizational publishers';

-- Categories table
CREATE TABLE IF NOT EXISTS categories
(
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    slug        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
) COMMENT ='Stores article categories';

-- Article status definitions
CREATE TABLE IF NOT EXISTS article_statuses
(
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
) COMMENT ='Defines possible article statuses';

-- Articles table
CREATE TABLE IF NOT EXISTS articles
(
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title          VARCHAR(255) NOT NULL,
    slug           VARCHAR(255) NOT NULL UNIQUE,
    content        LONGTEXT     NOT NULL,
    summary        TEXT,
    featured_image MEDIUMBLOB, -- Storing image Binary data MAX-SIZE: 16MB
    author_id      INT UNSIGNED NOT NULL,
    category_id    INT UNSIGNED NOT NULL,
    status_id      INT UNSIGNED NOT NULL,
    is_featured    BOOLEAN      DEFAULT FALSE,
    view_count     INT UNSIGNED DEFAULT 0,
    published_at   TIMESTAMP    NULL,
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users (id),
    FOREIGN KEY (category_id) REFERENCES categories (id),
    FOREIGN KEY (status_id) REFERENCES article_statuses (id),
    INDEX idx_articles_author (author_id),
    INDEX idx_articles_category (category_id),
    INDEX idx_articles_status (status_id),
    INDEX idx_articles_published (published_at),
    CONSTRAINT check_view_count CHECK (view_count >= 0)
) COMMENT ='Stores article content';


-- Comments table
CREATE TABLE IF NOT EXISTS comments
(
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    article_id  INT UNSIGNED NOT NULL,
    user_id     INT UNSIGNED NOT NULL,
    parent_id   INT UNSIGNED NULL,
    content     TEXT         NOT NULL,
    is_approved BOOLEAN   DEFAULT TRUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (parent_id) REFERENCES comments (id) ON DELETE CASCADE,
    INDEX idx_comments_article (article_id),
    INDEX idx_comments_user (user_id),
    INDEX idx_comments_parent (parent_id)
) COMMENT ='Stores user comments on articles';

-- Comment likes table
CREATE TABLE IF NOT EXISTS comment_likes
(
    user_id    INT UNSIGNED NOT NULL,
    comment_id INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, comment_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE
) COMMENT ='Tracks user likes on comments';

-- Article likes table
CREATE TABLE IF NOT EXISTS article_likes
(
    user_id    INT UNSIGNED NOT NULL,
    article_id INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, article_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE
) COMMENT ='Tracks user likes on articles';

-- Bookmarks table
CREATE TABLE IF NOT EXISTS bookmarks
(
    user_id    INT UNSIGNED NOT NULL,
    article_id INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, article_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE
) COMMENT ='Tracks user bookmarks';

-- System settings table
CREATE TABLE IF NOT EXISTS system_settings
(
    setting_key   VARCHAR(100) NOT NULL PRIMARY KEY,
    setting_value TEXT         NOT NULL,
    setting_group VARCHAR(50)  NOT NULL,
    description   TEXT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT ='Stores system configuration settings';

-- Audit log table for tracking important system changes
CREATE TABLE IF NOT EXISTS audit_logs
(
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED,
    action      VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50)  NOT NULL,
    entity_id   VARCHAR(50)  NOT NULL,
    details     JSON,
    ip_address  VARCHAR(45),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL,
    INDEX idx_audit_entity (entity_type, entity_id),
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_action (action),
    INDEX idx_audit_created (created_at)
) COMMENT ='Tracks system changes for security and debugging';