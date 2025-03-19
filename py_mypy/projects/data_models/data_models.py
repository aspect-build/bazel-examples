from pydantic import BaseModel
from typing import Optional

class Customer(BaseModel):
    customer_id: int
    name: str
    email: str

class Product(BaseModel):
    product_id: int
    name: str
    price: float

class OrderItem(BaseModel):
    product: Product
    quantity: int

class Order(BaseModel):
    order_id: int
    customer: Customer
    items: list[OrderItem]
    shipping_address: Optional[str] = None
