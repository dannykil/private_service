# FROM python:3.8-slim
FROM python:3.11-slim

RUN pip install --upgrade pip
RUN pip install numpy
RUN pip install pandas
RUN pip install faker
RUN pip install flask
# RUN pip install jinja
RUN pip install jinja2


COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

COPY app.py /

EXPOSE 5000

ENTRYPOINT ["python"]
CMD ["/app.py"]
