## Risk Test

### Understanding the Industry

**Explain the money flow and the information flow in the acquirer market and the role of the main players.**

I drew the flow to explain it better.

<img width="758" alt="Screenshot 2023-10-23 at 15 35 39" src="https://github.com/Hey-Feres/Risk-API/assets/43047693/4bd3455f-0337-45fd-b0a1-af53cf7086f8">

**Main roles**

- Merchants are businesses that sell goods or services utilizing acquiring banks' services to accept electronic payments from customers.

- Acquiring Banks provides merchants with the necessary tools and services to accept card payments.

- Card Networks acts as intermediaries, facilitating communication between acquiring banks and issuing banks.

- Issuing banks are the financial institutions that issue credit or debit cards to customers.

**Explain the difference between acquirer, sub-acquirer and payment gateway and how the flow explained in question 1 changes for these players.**

An **acquirer** is a financial institution that establishes and maintains relationships with merchants to enable them to accept electronic payments.
The **sub-acquirer** is a secondary level of acquiring banks or financial institutions. In cases of complex payment processing setups or international transactions, there could be multiple layers of acquiring entities involved.
The **Payment Gateway** is a technology service that acts as an intermediary between the merchant's website (or point of sale) and the acquirer. Is the responsible for security, authorization and handle the response.

**Explain what chargebacks are, how they differ from cancellations and what is their connection with fraud in the acquiring world.**

**Chargebacks** occur when a customer disputes a transaction with their issuing bank, and the funds from that transaction are reversed and returned to the cardholder.
A **Cancellation** occurs when a customer or merchant decides to void a transaction before it's settled or processed. In the case of a cancellation, no funds are moved, and the transaction is simply voided, usually before the product is shipped or the service is provided.

********************************

### Get your hands dirty

**Analyze the data provided and present your conclusions (consider that all transactions are made using a mobile device).**

We can focus on chargeback presence, quantity of a transactions in the same merchant in a row and short time range to avoid fraudulent behavior. It may also be interesting to pay attention on merchants and users with high ocurrence of chargebacks. The amount is another valuable param to prevent fraud, based on that param we can have an idea of user spending behavior and block transactions with amount much higher than the previous transactions.

**In addition to the spreadsheet data, what other data would you look at to try to find patterns of possible frauds?**

I believe a great ally in fraud prevention would be user geolocation data. Also a user spending profile based on his usual behavior and a score related to it. An analysis on website interaction behavior can help to identify a fraudulent bot as well.

