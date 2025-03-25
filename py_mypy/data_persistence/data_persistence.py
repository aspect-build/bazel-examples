from data_models import Order, Customer

def save_order(order: Order):
    with open(f"order_{order.order_id}.json", "w") as f:
        f.write(order.json()) # Pydantic's .json() method

def get_customer(customer_id: int) -> Customer | None:
    #Simulating customer retrieval. In real code this would be from a database.
    if customer_id == 1:
        return Customer(customer_id=1, name="John Doe", email="john.doe@example.com")
    return None

def update_stock(product_id: int, new_stock: int):
    #Simulating database update.
    print(f"Updating database: Product {product_id} stock to {new_stock}")
