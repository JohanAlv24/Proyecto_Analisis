from flask import Blueprint, render_template, request, send_file, url_for
import os, json, csv
import matlab.engine
import pandas as pd
import numpy as np

blueprint = Blueprint('seccion_2', __name__)

eng = matlab.engine.start_matlab()

separador = os.path.sep 
dir_actual = os.path.dirname(os.path.abspath(__file__))
dir_matlab = separador.join(dir_actual.split(separador)[:-1])+'\matlab'
dir_tables = os.path.join(dir_actual, 'tables')
dir_static = os.path.join(os.path.dirname(__file__), 'static')

eng.addpath(dir_matlab)

#Método de Gauss-Seidel
@blueprint.route('/gaussSeidel', methods=['GET', 'POST'])
def gaussSeidel():
    if request.method == 'POST':
        try:
            # Validar y procesar datos del formulario
            A = request.form['A']
            b = request.form['b']
            x = request.form['x']
            et = request.form['et']
            tol = float(request.form['tol'].replace(',', '.'))
            niter = int(request.form['niter'])

            # Validar las entradas del formulario
            if not A or not b or not x:
                raise ValueError("Debe ingresar las matrices A, b y el vector inicial x.")
            if tol <= 0:
                raise ValueError("La tolerancia debe ser un valor positivo.")
            if niter <= 0:
                raise ValueError("El número de iteraciones debe ser un entero positivo.")

            try:
                # Ejecutar MATLAB
                eng.addpath(dir_matlab)
                [r, N, xn, E, re, c] = eng.gaussSeidel(x, A, b, et, tol, niter, nargout=6)

                # Procesar resultados
                if isinstance(E, float) and np.isnan(E):
                    length = 0
                else:
                    N, xn, E = list(N[0]), list(xn[0]), list(E[0])
                    length = len(N)

                # Leer y procesar el archivo CSV generado por MATLAB
                tabla_path = os.path.join(dir_tables, 'tabla_gaussSeidel.csv')
                if os.path.exists(tabla_path):
                    df = pd.read_csv(tabla_path)
                    data = df.astype(str).to_dict(orient='records')
                else:
                    data = []

                # Procesar la ruta de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_gaussSeidel.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_gaussSeidel.png')

                # Renderizar resultados
                return render_template(
                    'Seccion_2/resultado_gaussSeidel.html',
                    r=r, N=N, xn=xn, E=E, Re=re, length=length, data=data,
                    imagen_path=imagen_path, c=c, niter=niter
                )

            except matlab.engine.MatlabExecutionError as matlab_error:
                # Capturar errores de MATLAB y renderizar el formulario con un mensaje de error
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    error_message=error_message
                )

        except ValueError as ve:
            # Errores específicos de validación
            error_message = str(ve)
            return render_template(
                'Seccion_2/formulario_gaussSeidel.html',
                error_message=error_message
            )

        except Exception as e:
            # Capturar cualquier otro error
            error_message = f"Error de sintaxis, para mas informacion ir al apartado de ayuda"
            return render_template(
                'Seccion_2/formulario_gaussSeidel.html',
                error_message=error_message
            )

    # Si es una solicitud GET, renderizar el formulario vacío
    return render_template('Seccion_2/formulario_gaussSeidel.html')


@blueprint.route('/gaussSeidel/descargar', methods=['POST'])
def descargar_archivo_gaussSeidel():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_gaussSeidel.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)

#Método de Jacobi
@blueprint.route('/jacobi', methods=['GET', 'POST'])
def jacobi():
    if request.method == 'POST':
        try:
            # Validar y procesar datos del formulario
            A = request.form['A']
            b = request.form['b']
            x = request.form['x']
            error_type = request.form['error_type']
            tol = float(request.form['tol'].replace(',', '.'))
            niter = int(request.form['niter'])

            # Validar entradas
            if not A or not b or not x:
                raise ValueError("Debe ingresar las matrices A, b y el vector inicial x.")
            if tol <= 0:
                raise ValueError("La tolerancia debe ser un valor positivo.")
            if niter <= 0:
                raise ValueError("El número de iteraciones debe ser un entero positivo.")

            try:
                # Ejecutar MATLAB
                eng.addpath(dir_matlab)
                [r, N, xn, E, Re] = eng.jacobi(x, A, b, tol, niter, error_type, nargout=5)

                # Procesar resultados
                if not np.isnan(xn[0][0]):
                    N, E = list(N[0]), list(E[0])
                    length = len(N)
                else:
                    length = 0

                # Leer y procesar el archivo CSV generado por MATLAB
                tabla_path = os.path.join(dir_tables, 'tabla_jacobi.csv')
                if os.path.exists(tabla_path):
                    df = pd.read_csv(tabla_path)
                    data = df.astype(str).to_dict(orient='records')
                else:
                    data = []

                # Procesar la ruta de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_jacobi.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_jacobi.png')

                # Renderizar resultados
                return render_template(
                    'Seccion_2/resultado_jacobi.html',
                    r=r, N=N, xn=xn, E=E, Re=Re, length=length, data=data,
                    imagen_path=imagen_path
                )

            except matlab.engine.MatlabExecutionError as matlab_error:
                # Capturar errores de MATLAB y renderizar el formulario con un mensaje de error
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    error_message=error_message
                )

        except ValueError as ve:
            # Errores específicos de validación
            error_message = str(ve)
            return render_template(
                'Seccion_2/formulario_jacobi.html',
                error_message=error_message
            )

        except Exception as e:
            # Capturar cualquier otro error
            error_message = "Error de sintaxis, para más información ir al apartado de ayuda."
            return render_template(
                'Seccion_2/formulario_jacobi.html',
                error_message=error_message
            )

    # Si es una solicitud GET, renderizar el formulario vacío
    return render_template('Seccion_2/formulario_jacobi.html')


@blueprint.route('/jacobi/descargar', methods=['POST'])
def descargar_archivo_jacobi():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_jacobi.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)


#Método de sor
@blueprint.route('/sor', methods=['GET', 'POST'])
def sor():
    if request.method == 'POST':
        try:
            # Validar y procesar datos del formulario
            x0 = str(request.form['x'])
            A = request.form['A']
            b = str(request.form['b'])
            Tol = float(request.form['tol'].replace(',', '.'))
            niter = int(request.form['niter'])
            w = float(request.form['w'].replace(',', '.'))
            tipe = str(request.form['et'])

            # Validaciones de entrada
            if not A or not b or not x0:
                raise ValueError("Debe ingresar las matrices A, b y el vector inicial x.")
            if Tol <= 0:
                raise ValueError("La tolerancia debe ser un valor positivo.")
            if niter <= 0:
                raise ValueError("El número de iteraciones debe ser un entero positivo.")
            if w <= 0 or w > 2:
                raise ValueError("El factor de relajación (w) debe estar entre 0 y 2.")

            try:
                # Ejecutar MATLAB
                eng.addpath(dir_matlab)
                [r, n, xi, E, radio] = eng.SOR(x0, A, b, Tol, niter, w, tipe, nargout=5)

                # Procesar resultados
                if not np.isnan(xi[0][0]):
                    n, E = list(n[0]), list(E[0])
                    length = len(n)
                else:
                    length = 0

                xi = [[xi[j][i] for j in range(len(xi))] for i in range(len(xi[0]))]

                # Leer y procesar el archivo CSV generado por MATLAB
                tabla_path = os.path.join(dir_tables, 'tabla_sor.csv')
                if os.path.exists(tabla_path):
                    df = pd.read_csv(tabla_path)
                    data = df.astype(str).to_dict(orient='records')
                else:
                    data = []

                # Procesar la ruta de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_sor.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_sor.png')

                # Renderizar resultados
                return render_template(
                    'Seccion_2/resultado_sor.html',
                    r=r, n=n, xi=xi, E=E, radio=radio, length=length, data=data,
                    imagen_path=imagen_path
                )

            except matlab.engine.MatlabExecutionError as matlab_error:
                # Capturar errores de MATLAB y renderizar el formulario con un mensaje de error
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    'Seccion_2/formulario_sor.html',
                    error_message=error_message
                )

        except ValueError as ve:
            # Errores específicos de validación
            error_message = str(ve)
            return render_template(
                'Seccion_2/formulario_sor.html',
                error_message=error_message
            )

        except Exception as e:
            # Capturar cualquier otro error
            error_message = "Error de sintaxis, para más información ir al apartado de ayuda."
            return render_template(
                'Seccion_2/formulario_sor.html',
                error_message=error_message
            )

    # Si es una solicitud GET, renderizar el formulario vacío
    return render_template('Seccion_2/formulario_sor.html')


@blueprint.route('/sor/descargar', methods=['POST'])
def descargar_archivo_sor():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_sor.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)

