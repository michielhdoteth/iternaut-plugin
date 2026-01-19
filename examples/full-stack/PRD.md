# E-Commerce Dashboard

## Overview

Build a full-stack e-commerce admin dashboard for managing products, orders, and customers.

## Goals

1. Dashboard with key metrics
2. Product management (CRUD)
3. Order management
4. Customer management
5. Real-time sales analytics

## Tech Stack

- **Frontend**: React + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + PostgreSQL
- **State**: React Query
- **Charts**: Recharts
- **Testing**: Jest + React Testing Library

## User Stories

1. As an admin, I see dashboard with sales metrics
2. As an admin, I can view all products
3. As an admin, I can add new products
4. As an admin, I can edit product details
5. As an admin, I can delete products
6. As an admin, I can view orders
7. As an admin, I can update order status
8. As an admin, I can view customer list
9. As an admin, I can search products

## Pages

- `/` - Dashboard with metrics
- `/products` - Product list
- `/products/:id` - Product detail/edit
- `/orders` - Order list
- `/orders/:id` - Order detail
- `/customers` - Customer list

## Components

- MetricsCard
- SalesChart
- ProductTable
- ProductForm
- OrderTable
- OrderDetail
- CustomerTable

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/dashboard/metrics | Dashboard metrics |
| GET | /api/products | List products |
| POST | /api/products | Create product |
| GET | /api/products/:id | Get product |
| PUT | /api/products/:id | Update product |
| DELETE | /api/products/:id | Delete product |
| GET | /api/orders | List orders |
| PUT | /api/orders/:id/status | Update order status |
| GET | /api/customers | List customers |

## Success Criteria

- All pages responsive
- 80% test coverage
- No console errors
- Fast page loads (<2s)
