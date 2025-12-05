-- PostgreSQL initialization script for pgvector DB
-- This script is executed when the container is first started

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Note: pgvector extension requires installation first
-- If you need vector similarity search, uncomment the following line
-- and make sure pgvector is installed in your PostgreSQL image
-- CREATE EXTENSION IF NOT EXISTS vector;

-- Create schema for pgvector
CREATE SCHEMA IF NOT EXISTS pgvector;

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON SCHEMA pgvector TO "user";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA pgvector TO "user";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA pgvector TO "user";

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA pgvector GRANT ALL ON TABLES TO "user";
ALTER DEFAULT PRIVILEGES IN SCHEMA pgvector GRANT ALL ON SEQUENCES TO "user";

-- Create a sample table for storing documents (if needed)
-- Uncomment and modify based on your requirements
/*
CREATE TABLE IF NOT EXISTS pgvector.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on metadata for faster queries
CREATE INDEX IF NOT EXISTS idx_documents_metadata ON pgvector.documents USING GIN (metadata);
*/

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully';
END $$;
