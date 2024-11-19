from flask import Blueprint, render_template, request, send_file, url_for
import os, json, csv
import matlab.engine
import pandas as pd
import numpy as np

blueprint = Blueprint('seccion_3', __name__)

eng = matlab.engine.start_matlab()

separador = os.path.sep 
dir_actual = os.path.dirname(os.path.abspath(__file__))
dir_matlab = separador.join(dir_actual.split(separador)[:-1])+'\matlab'
dir_tables = os.path.join(dir_actual, 'tables')
dir_static = os.path.join(os.path.dirname(__file__), 'static')

eng.addpath(dir_matlab)

@blueprint.route('/lagrange', methods=['POST', 'GET'])
def lagrange():
    if request.method == 'POST':
        try:
            x = json.loads(request.form['vectorx'])
            y = json.loads(request.form['vectory'])

            # Validar que los vectores no estén vacíos
            if len(x) < 2 or len(y) < 2:
                raise ValueError("Debes ingresar al menos dos puntos para realizar el método.")
            if len(x) != len(y):
                raise ValueError("Los vectores X e Y deben tener la misma longitud.")
            
            eng.addpath(dir_matlab)

            # Convertir vectores a formato MATLAB
            matx = matlab.double(x)
            maty = matlab.double(y)

            # Llamar al método de MATLAB
            try:
                respuesta = eng.lagrange(matx, maty)
                print("respuesta", respuesta)

                # Leer y procesar el archivo CSV generado
                tabla_path = os.path.join(dir_tables, 'tabla_lagrange.csv')
                if os.path.exists(tabla_path):
                    df = pd.read_csv(tabla_path)
                    polinomio = df['Polinomio'][0]
                    data = df.to_dict(orient='records')
                    df.to_excel(os.path.join(dir_tables, 'tabla_lagrange.xlsx'), index=False)
                else:
                    raise FileNotFoundError("No se encontró el archivo de resultados de MATLAB.")

                # Verificar la existencia de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_lagrange.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_lagrange.png')

                return render_template(
                    'Seccion_3/resultado_lagrange.html',
                    respuesta=polinomio, data=data, imagen_path=imagen_path
                )
            except matlab.engine.MatlabExecutionError as matlab_error:
                # Capturar errores específicos de MATLAB
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    'Seccion_3/lagrange.html',
                    error_message=error_message
                )
        except ValueError as ve:
            # Errores específicos de validación de datos
            error_message = str(ve)
            return render_template(
                'Seccion_3/lagrange.html',
                error_message=error_message
            )
        except Exception as e:
            # Manejo general de errores
            error_message = f"Ha ocurrido un error inesperado: {str(e)}"
            return render_template(
                'Seccion_3/lagrange.html',
                error_message=error_message
            )

    return render_template('Seccion_3/lagrange.html')


@blueprint.route('/lagrange/descargar', methods=['POST'])
def descargar_archivoLagrange():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_lagrange.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)

@blueprint.route('/newtonint', methods=['POST', 'GET'])
def newtonint():
    if request.method == 'POST':
        try:
            x = json.loads(request.form['vectorx'])
            y = json.loads(request.form['vectory'])

            # Validaciones iniciales
            if len(x) < 2 or len(y) < 2:
                raise ValueError("Debes ingresar al menos dos puntos.")
            if len(x) != len(y):
                raise ValueError("Los vectores X e Y deben tener la misma longitud.")

            eng.addpath(dir_matlab)

            # Convertir a formato MATLAB
            matx = matlab.double(x)
            maty = matlab.double(y)

            # Llamar al método de MATLAB
            try:
                respuesta = eng.Newtonint(matx, maty)

                # Leer y procesar el archivo CSV generado
                tabla_path = os.path.join(dir_tables, 'tabla_polnewton.csv')
                if os.path.exists(tabla_path):
                    df = pd.read_csv(tabla_path)
                    polinomio = df['Polinomio'][0]
                else:
                    raise FileNotFoundError("No se encontró el archivo de resultados de MATLAB.")

                # Procesar tabla de resultados
                tabla_resultados_path = os.path.join(dir_tables, 'tabla_newtonint.csv')
                if os.path.exists(tabla_resultados_path):
                    data = pd.read_csv(tabla_resultados_path).to_dict(orient='records')
                    pd.read_csv(tabla_resultados_path).to_excel(
                        os.path.join(dir_tables, 'tabla_newtonint.xlsx'),
                        index=False
                    )
                else:
                    data = []

                # Verificar la existencia de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_newtonint.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_newtonint.png')

                return render_template(
                    'Seccion_3/resultado_newtonint.html',
                    respuesta=polinomio, data=data, imagen_path=imagen_path
                )
            except matlab.engine.MatlabExecutionError as matlab_error:
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    'Seccion_3/newtonint.html',
                    error_message=error_message
                )
        except ValueError as ve:
            error_message = str(ve)
            return render_template(
                'Seccion_3/newtonint.html',
                error_message=error_message
            )
        except Exception as e:
            error_message = f"Ha ocurrido un error inesperado: {str(e)}"
            return render_template(
                'Seccion_3/newtonint.html',
                error_message=error_message
            )

    return render_template('Seccion_3/newtonint.html')


@blueprint.route('/newtonint/descargar', methods=['POST'])
def descargar_archivoNewtonInt():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_newtonInt.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)


@blueprint.route('/vandermonde', methods=['POST', 'GET'])
def vandermonde():
    if request.method == 'POST':
        try:
            x = json.loads(request.form['vectorx'])
            y = json.loads(request.form['vectory'])

            # Validaciones iniciales
            if len(x) < 2 or len(y) < 2:
                raise ValueError("Debes ingresar al menos dos puntos.")
            if len(x) != len(y):
                raise ValueError("Los vectores X e Y deben tener la misma longitud.")

            eng.addpath(dir_matlab)

            # Convertir a formato MATLAB
            matx = matlab.double(x)
            maty = matlab.double(y)

            # Llamar al método de MATLAB
            try:
                respuesta = eng.vander(matx, maty)

                # Leer el archivo CSV generado
                csv_path = os.path.join(dir_tables, 'pol_vandermonde.csv')
                if os.path.exists(csv_path):
                    df = pd.read_csv(csv_path)
                    polinomio = df['Polinomio'][0]
                    data = df.to_dict(orient='records')
                    df.to_excel(os.path.join(dir_tables, 'pol_vandermonde.xlsx'), index=False)
                else:
                    raise FileNotFoundError("No se encontró el archivo de resultados de MATLAB.")

                # Verificar la existencia de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_vander.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_vander.png')

                return render_template(
                    'Seccion_3/resultado_vander.html',
                    respuesta=polinomio, data=data, imagen_path=imagen_path
                )
            except matlab.engine.MatlabExecutionError as matlab_error:
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template('Seccion_3/vandermonde.html', error_message=error_message)
        except ValueError as ve:
            error_message = str(ve)
            return render_template('Seccion_3/vandermonde.html', error_message=error_message)
        except Exception as e:
            error_message = f"Ha ocurrido un error inesperado: {str(e)}"
            return render_template('Seccion_3/vandermonde.html', error_message=error_message)

    return render_template('Seccion_3/vandermonde.html')

@blueprint.route('/vandermonde/descargar', methods=['POST'])
def descargar_polvander():
    archivo_path = 'tables/pol_vandermonde.xlsx'

    return send_file(archivo_path, as_attachment=True)


@blueprint.route('/spline', methods=['POST', 'GET'])
@blueprint.route('/spline', methods=['GET', 'POST'])
def spline():
    if request.method == 'POST':
        try:
            # Obtener y validar datos del formulario
            x = json.loads(request.form['x'])
            y = json.loads(request.form['y'])
            d = int(request.form['d'])

            if len(x) < 2 or len(y) < 2:
                raise ValueError("Debes ingresar al menos dos puntos para realizar el método.")
            if len(x) != len(y):
                raise ValueError("Los vectores X e Y deben tener la misma longitud.")
            if d not in [1, 2, 3]:
                raise ValueError("El grado del trazador debe ser 1 (lineal), 2 (cuadrático) o 3 (cúbico).")

            # Ejecutar MATLAB
            eng.addpath(dir_matlab)
            respuesta = eng.spline(json.dumps(x), json.dumps(y), d)

            # Leer resultados
            csv_path = os.path.join(dir_tables, 'tabla_spline.csv')
            if os.path.exists(csv_path):
                df = pd.read_csv(csv_path)
                data = df.astype(str).to_dict(orient='records')
                df.to_excel(os.path.join(dir_tables, 'tabla_spline.xlsx'), index=False)
            else:
                raise FileNotFoundError("No se encontró el archivo de resultados de MATLAB.")

            # Procesar gráfica
            imagen_path = os.path.join(dir_static, 'grafica_spline.png')
            if not os.path.exists(imagen_path):
                imagen_path = None
            else:
                imagen_path = url_for('static', filename='grafica_spline.png')

            # Generar grados para la plantilla
            grados = list(range(1, d + 1))

            return render_template(
                'Seccion_3/resultado_spline.html',
                respuesta=respuesta, data=data, imagen_path=imagen_path, x=x, grados=grados, grado=d
            )

        except ValueError as ve:
            error_message = str(ve)
            return render_template('Seccion_3/spline.html', error_message=error_message)

        except Exception as e:
            error_message = f"Ha ocurrido un error inesperado: {str(e)}"
            return render_template('Seccion_3/spline.html', error_message=error_message)

    return render_template('Seccion_3/spline.html')


@blueprint.route('/spline/descargar', methods=['POST'])
def descargar_archivoSpline():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_spline.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)