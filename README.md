# Inventory Management System

A PostgreSQL-based inventory management system that tracks products, orders, warehouses, employees and inventory levels across multiple geographical locations.

## Table of Contents

- [Project Overview](#project-overview)
- [Database Schema](#database-schema)
- [Features](#features)
- [Files](#files)
- [Key Functionalities](#key-functionalities)
- [Technical Details](#technical-details)
- [Data Import Process](#data-import-process)
- [Setup Instructions](#setup-instructions)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Future Enhancements](#future-enhancements)
- [Contributions](#contributions)

## Project Overview

This database system manages:

- Product inventory and stock levels
- Customer orders and order items
- Warehouse locations and employees
- Automated reordering system
- Geographic location hierarchy (regions, countries, states, cities)

## Database Schema

The database consists of the following key tables:

- Region, Country, State, City (Geographic hierarchy)
- Warehouse (Physical locations)
- Employee (Warehouse staff)
- Category (Product categories)
- Product (Product details)
- Customer (Customer information)
- OrderTable (Order headers)
- OrderItem (Order line items)
- Inventory (Stock levels)
- ReorderRequests (Automated reordering)

![Database Schema](dbdiagram.png)

## Features

- **Geographic Organization**: Hierarchical structure from regions down to cities
- **Inventory Tracking**: Real-time stock level monitoring
- **Automated Reordering**: Triggers reorder requests when stock falls below thresholds
- **Order Management**: Complete order processing system
- **Employee Management**: Tracks warehouse staff and their roles

## Files

- `create_database.sql`: SQL scripts to create database schema and populate tables
- `dbdiagram_code.sql`: SQL code representing database diagram structure
- `dbdiagram.png`: Visual representation of database schema
- `ML-DATASET.csv`: Sample data for testing and initial database population

## Key Functionalities

1. **Inventory Management**

   - Stock level tracking
   - Reorder threshold monitoring
   - Automated reorder request generation

2. **Order Processing**

   - Customer order tracking
   - Order item management
   - Shipping status updates

3. **Location Management**
   - Warehouse organization
   - Geographic hierarchy
   - Employee assignment

## Technical Details

- **Database**: PostgreSQL
- **Triggers**: Automatic inventory updates on sales
- **Stored Procedures**: Automated reordering process
- **Foreign Keys**: Referential integrity across all tables
- **Sequences**: Automated ID generation

## Data Import Process

1. Initial staging table creation
2. CSV data import
3. Data distribution to normalized tables
4. Sequence resets for proper ID management

## Setup Instructions

1. Create PostgreSQL database
2. Run `create_database.sql` to create schema
3. Import data from `ML-DATASET.csv`
4. Verify table population
5. Test functionality

## Monitoring and Maintenance

- Regular inventory level checks
- Reorder request processing
- Employee assignment updates
- Order fulfillment tracking

## Future Enhancements

- Real-time reporting dashboard
- Predictive inventory management
- Supplier integration
- Mobile application interface

## Contributions

### Dataset Source

The initial dataset used in this project was sourced from [Inventory Management Dataset](https://www.kaggle.com/datasets/hetulparmar/inventory-management-dataset) on Kaggle by Hetul Parmar.

### Contributing Guidelines

1. Fork the repository
2. Create a new branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Commit your changes (`git commit -am 'Add new feature'`)
5. Push to the branch (`git push origin feature/improvement`)
6. Create a Pull Request

### Areas for Contribution

- Additional analytics queries
- Performance optimizations
- Documentation improvements
- Bug fixes
- New features
- Test cases

### Code of Conduct

- Be respectful of others' contributions
- Document significant changes
- Follow existing code style
- Write clear commit messages
- Test before submitting PRs
