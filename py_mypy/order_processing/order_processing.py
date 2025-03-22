from data_models import Order, Customer, Product, OrderItem
from data_persistence import save_order, get_customer
from typing import List

def create_order(customer_id: int, items: List[tuple[int, int]], shipping_address: str | None = None) -> Order:
    customer = get_customer(customer_id)
    if not customer:
        raise ValueError("Customer not found")

    order_items = []
    for product_id, quantity in items:
        #Simulating product retrieval. In real code this would be from data_persistence.
        product = Product(product_id=product_id, name=f"Product {product_id}", price=10.0 * product_id)
        order_items.append(OrderItem(product=product, quantity=quantity))

    order = Order(order_id=123, customer=customer, items=order_items, shipping_address=shipping_address) #Order id would be generated in real application.
    save_order(order)
    return order

def update_order_shipping(order_id: int, new_address: str):
    #Simulating order retrieval and update. In real code this would be from data_persistence.
    print(f"Updating order {order_id} shipping to {new_address}")
