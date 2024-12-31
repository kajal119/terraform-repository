from flask import Flask, jsonify, abort
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

app = Flask(__name__)
s3_client = boto3.client('s3')

BUCKET_NAME = 'http-bucket-task'

@app.route('/list-bucket-content', defaults={'path': ''})
@app.route('/list-bucket-content/<path:path>')
def list_bucket_content(path):
    try:
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=path, Delimiter='/')
        if 'Contents' not in response and 'CommonPrefixes' not in response:
            return jsonify({"content": []})

        contents = [item.get('Key') or item.get('Prefix') for item in response.get('Contents', []) + response.get('CommonPrefixes', [])]
        return jsonify({"content": contents})

    except s3_client.exceptions.NoSuchBucket:
        abort(404, description="Bucket not found")
    except NoCredentialsError:
        abort(500, description="AWS credentials not found")
    except PartialCredentialsError:
        abort(500, description="Incomplete AWS credentials")

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)
